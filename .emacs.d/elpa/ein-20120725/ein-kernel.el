;;; ein-kernel.el --- Communicate with IPython notebook server

;; Copyright (C) 2012- Takafumi Arakaki

;; Author: Takafumi Arakaki <aka.tkf at gmail.com>

;; This file is NOT part of GNU Emacs.

;; ein-kernel.el is free software: you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; ein-kernel.el is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with ein-kernel.el.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;;

;;; Code:

(eval-when-compile (require 'cl))
(require 'ansi-color)

(require 'ein-log)
(require 'ein-utils)
(require 'ein-websocket)
(require 'ein-events)
(require 'ein-query)


(defstruct ein:$kernel
  "Hold kernel variables.

`ein:$kernel-url-or-port'
  URL or port of IPython server.

FIXME: document other slots."
  url-or-port
  events
  kernel-id
  shell-channel
  iopub-channel
  base-url
  kernel-url
  ws-url
  running
  username
  session-id
  msg-callbacks
  after-start-hook
  after-execute-hook
  kernelinfo)


(defstruct ein:$kernelinfo
  "Info related (but unimportant) to kernel

`ein:$kernelinfo-buffer'
  Notebook buffer that the kernel associated with.

`ein:$kernelinfo-hostname'
  Host name of the machine where the kernel is running on.

`ein:$kernelinfo-ccwd'
  cached CWD (last time checked CWD)."
  buffer
  hostname
  ccwd)


;;; Initialization and connection.

(defun ein:kernel-new (url-or-port base-url events)
  (make-ein:$kernel
   :url-or-port url-or-port
   :events events
   :kernel-id nil
   :shell-channel nil
   :iopub-channel nil
   :base-url base-url
   :running nil
   :username "username"
   :session-id (ein:utils-uuid)
   :msg-callbacks (make-hash-table :test 'equal)
   :kernelinfo (make-ein:$kernelinfo)))


(defun ein:kernel-del (kernel)
  "Destructor for `ein:$kernel'."
  (ein:kernel-stop-channels kernel))


(defun ein:kernel--get-msg (kernel msg-type content)
  (list
   :header (list
            :msg_id (ein:utils-uuid)
            :username (ein:$kernel-username kernel)
            :session (ein:$kernel-session-id kernel)
            :msg_type msg-type)
   :content content
   :parent_header (make-hash-table)))


(defun ein:kernel-start (kernel notebook-id)
  "Start kernel of the notebook whose id is NOTEBOOK-ID."
  (unless (ein:$kernel-running kernel)
    (ein:query-singleton-ajax
     (list 'kernel-start (ein:$kernel-kernel-id kernel))
     (concat (ein:url (ein:$kernel-url-or-port kernel)
                      (ein:$kernel-base-url kernel))
             "?" (format "notebook=%s" notebook-id))
     :type "POST"
     :parser #'ein:json-read
     :success (cons #'ein:kernel--kernel-started kernel))))


(defun ein:kernel-restart (kernel)
  (ein:events-trigger (ein:$kernel-events kernel)
                      'status_restarting.Kernel)
  (ein:log 'info "Restarting kernel")
  (when (ein:$kernel-running kernel)
    (ein:kernel-stop-channels kernel)
    (ein:query-singleton-ajax
     (list 'kernel-restart (ein:$kernel-kernel-id kernel))
     (ein:url (ein:$kernel-url-or-port kernel)
              (ein:$kernel-kernel-url kernel)
              "restart")
     :type "POST"
     :parser #'ein:json-read
     :success (cons #'ein:kernel--kernel-started kernel))))


(defun* ein:kernel--kernel-started (kernel &key data &allow-other-keys)
  (ein:log 'info "Kernel started: %s" (plist-get data :kernel_id))
  (setf (ein:$kernel-running kernel) t)
  (setf (ein:$kernel-kernel-id kernel) (plist-get data :kernel_id))
  (setf (ein:$kernel-ws-url kernel) (plist-get data :ws_url))
  (setf (ein:$kernel-kernel-url kernel)
        (concat (ein:$kernel-base-url kernel) "/"
                (ein:$kernel-kernel-id kernel)))
  (ein:kernel-start-channels kernel)
  (let ((shell-channel (ein:$kernel-shell-channel kernel))
        (iopub-channel (ein:$kernel-iopub-channel kernel)))
    ;; FIXME: get rid of lexical-let
    (lexical-let ((kernel kernel))
      (setf (ein:$websocket-onmessage shell-channel)
            (lambda (packet)
              (ein:kernel--handle-shell-reply kernel packet)))
      (setf (ein:$websocket-onmessage iopub-channel)
            (lambda (packet)
              (ein:kernel--handle-iopub-reply kernel packet))))))


(defun ein:kernel--websocket-closed (kernel ws-url early)
  ;; FIXME: `message' is not good choice for showing multiple line
  ;; message.  I should implement ein-pager.el first and show the
  ;; message using its function.
  (if early
      (ein:log 'warn
       "Websocket connection to %s could not be established. \
You will NOT be able to run code. \
Your websocket.el may not be compatible with the websocket version in \
the server, or if the url does not look right, there could be an \
error in the server's configuration." ws-url)
    (ein:log 'warn "Websocket connection closed unexpectedly. \
The kernel will no longer be responsive.")))


(defun ein:kernel-send-cookie (channel)
  ;; This is required to open channel.  In IPython's kernel.js, it sends
  ;; `document.cookie'.  This is an empty string anyway.
  (ein:websocket-send channel ""))


(defun ein:kernel--ws-closed-callback (websocket kernel arg)
  ;; NOTE: The argument ARG should not be "unpacked" using `&rest'.
  ;; It must be given as a list to hold state `already-called-onclose'
  ;; so it can be modified in this function.
  (destructuring-bind (&key already-called-onclose ws-url early)
      arg
    (unless already-called-onclose
      (plist-put arg :already-called-onclose t)
      (unless (ein:$websocket-closed-by-client websocket)
        ;; Use "event-was-clean" when it is implemented in websocket.el.
        (ein:kernel--websocket-closed kernel ws-url early)))))


(defun ein:kernel-start-channels (kernel)
    (ein:kernel-stop-channels kernel)
    (let* ((ws-url (concat (ein:$kernel-ws-url kernel)
                           (ein:$kernel-kernel-url kernel)))
           (onclose-arg (list :ws-url ws-url
                              :already-called-onclose nil
                              :early t)))
      (ein:log 'info "Starting WS: %S" ws-url)
      (setf (ein:$kernel-shell-channel kernel)
            (ein:websocket (concat ws-url "/shell")))
      (setf (ein:$kernel-iopub-channel kernel)
            (ein:websocket (concat ws-url "/iopub")))

      (loop for c in (list (ein:$kernel-shell-channel kernel)
                           (ein:$kernel-iopub-channel kernel))
            do (setf (ein:$websocket-onclose-args c) (list kernel onclose-arg))
            do (setf (ein:$websocket-onopen c)
                     (lexical-let ((channel c)
                                   (kernel kernel))
                       (lambda ()
                         (ein:kernel-send-cookie channel)
                         ;; run `ein:$kernel-after-start-hook' if both
                         ;; channels are ready.
                         (when (ein:kernel-live-p kernel)
                           (ein:kernel-run-after-start-hook kernel)))))
            do (setf (ein:$websocket-onclose c)
                     #'ein:kernel--ws-closed-callback))

      ;; switch from early-close to late-close message after 1s
      (run-at-time
       1 nil
       (lambda (onclose-arg)
         (plist-put onclose-arg :early nil)
         (ein:log 'debug "(via run-at-time) onclose-arg changed to: %S"
                  onclose-arg))
       onclose-arg)))

;; NOTE: `onclose-arg' can be accessed as:
;; (nth 1 (ein:$websocket-onclose-args (ein:$kernel-shell-channel (ein:$notebook-kernel ein:notebook))))


(defun ein:kernel-run-after-start-hook (kernel)
  (ein:log 'debug "EIN:KERNEL-RUN-AFTER-START-HOOK")
  (mapc #'ein:funcall-packed
        (ein:$kernel-after-start-hook kernel)))


(defun ein:kernel-stop-channels (kernel)
  (when (ein:$kernel-shell-channel kernel)
    (setf (ein:$websocket-onclose (ein:$kernel-shell-channel kernel)) nil)
    (ein:websocket-close (ein:$kernel-shell-channel kernel))
    (setf (ein:$kernel-shell-channel kernel) nil))
  (when (ein:$kernel-iopub-channel kernel)
    (setf (ein:$websocket-onclose (ein:$kernel-iopub-channel kernel)) nil)
    (ein:websocket-close (ein:$kernel-iopub-channel kernel))
    (setf (ein:$kernel-iopub-channel kernel) nil)))


(defun ein:kernel-live-p (kernel)
  (and
   (ein:aand (ein:$kernel-shell-channel kernel) (ein:websocket-open-p it))
   (ein:aand (ein:$kernel-iopub-channel kernel) (ein:websocket-open-p it))))


(defmacro ein:kernel-if-ready (kernel &rest body)
  "Execute BODY if KERNEL is ready.  Warn user otherwise."
  (declare (indent 1))
  `(if (ein:kernel-live-p ,kernel)
       (progn ,@body)
     (ein:log 'warn "Kernel is not ready yet! (or closed already.)")))


;;; Main public methods

;; NOTE: The argument CALLBACKS for the following functions is almost
;;       same as the JS implementation in IPython.  However, as Emacs
;;       lisp does not support closure, value is "packed" using
;;       `cons': `car' is the actual callback function and `cdr' is
;;       its first argument.  It's like using `cons' instead of
;;       `$.proxy'.

(defun ein:kernel-object-info-request (kernel objname callbacks)
  "Send object info request of OBJNAME to KERNEL.

When calling this method pass a CALLBACKS structure of the form:

    (:object_info_reply (FUNCTION . ARGUMENT))

The FUNCTION will be passed the ARGUMENT as the first argument
and the `content' object of the `object_into_reply' message as
the second argument.

`object_into_reply' message is documented here:
http://ipython.org/ipython-doc/dev/development/messaging.html#object-information
"
  (assert (ein:kernel-live-p kernel) nil "Kernel is not active.")
  (when objname
    (let* ((content (list :oname (format "%s" objname)))
           (msg (ein:kernel--get-msg kernel "object_info_request" content))
           (msg-id (plist-get (plist-get msg :header) :msg_id)))
      (ein:websocket-send
       (ein:$kernel-shell-channel kernel)
       (json-encode msg))
      (ein:kernel-set-callbacks-for-msg kernel msg-id callbacks)
      msg-id)))


(defun* ein:kernel-execute (kernel code &optional callbacks
                                   &key
                                   (silent t)
                                   (user-variables [])
                                   (user-expressions (make-hash-table))
                                   (allow-stdin json-false))
  "Execute CODE on KERNEL.

When calling this method pass a CALLBACKS structure of the form:

  (:execute_reply  EXECUTE-REPLY-CALLBACK
   :output         OUTPUT-CALLBACK
   :clear_output   CLEAR-OUTPUT-CALLBACK
   :set_next_input SET-NEXT-INPUT)

Objects end with -CALLBACK above must pack a FUNCTION and its
first ARGUMENT in a `cons':

  (FUNCTION . ARGUMENT)

Call signature of the callbacks:

Callback                `msg_type'        Extra arguments        Notes
----------------------  ----------------  ---------------------  ------------
EXECUTE-REPLY-CALLBACK  `execute_reply'   `content'
OUTPUT-CALLBACK         [#output]_        `msg_type' `content'   [#output2]_
CLEAR-OUTPUT-CALLBACK   `clear_output'    `content'              [#clear]_

For example, the EXECUTE-REPLY-CALLBACK is called as:
  (`funcall' FUNCTION ARGUMENT CONTENT)

.. [#output]  One of `stream', `display_data', `pyout', `pyerr'.
.. [#output2] The argument MSG-ID for the FUNCTION is a string.
.. [#clear]_  Content object has `stdout', `stderr' and `other'
              fields that are booleans.

`execute_reply' message is documented here:
http://ipython.org/ipython-doc/dev/development/messaging.html#execute
Output type messages is documented here:
http://ipython.org/ipython-doc/dev/development/messaging.html#messages-on-the-pub-sub-socket

The SET-NEXT-INPUT callback will be passed the `set_next_input' payload.

See `ein:kernel--handle-shell-reply' for how the callbacks are called."
  (assert (ein:kernel-live-p kernel) nil "Kernel is not active.")
  (let* ((content (list
                   :code code
                   :silent (or silent json-false)
                   :user_variables user-variables
                   :user_expressions user-expressions
                   :allow_stdin allow-stdin))
         (msg (ein:kernel--get-msg kernel "execute_request" content))
         (msg-id (plist-get (plist-get msg :header) :msg_id)))
    (ein:websocket-send
     (ein:$kernel-shell-channel kernel)
     (json-encode msg))
    (ein:kernel-set-callbacks-for-msg kernel msg-id callbacks)
    (unless silent
      (mapc #'ein:funcall-packed
            (ein:$kernel-after-execute-hook kernel)))
    msg-id))


(defun ein:kernel-complete (kernel line cursor-pos callbacks)
  "Complete code at CURSOR-POS in a string LINE on KERNEL.

CURSOR-POS is the position in the string LINE, not in the buffer.

When calling this method pass a CALLBACKS structure of the form:

    (:complete_reply (FUNCTION . ARGUMENT))

The FUNCTION will be passed the ARGUMENT as the first argument and
the `content' object of the `complete_reply' message as the second.

`complete_reply' message is documented here:
http://ipython.org/ipython-doc/dev/development/messaging.html#complete
"
  (assert (ein:kernel-live-p kernel) nil "Kernel is not active.")
  (let* ((content (list
                   :text ""
                   :line line
                   :cursor_pos cursor-pos))
         (msg (ein:kernel--get-msg kernel "complete_request" content))
         (msg-id (plist-get (plist-get msg :header) :msg_id)))
    (ein:websocket-send
     (ein:$kernel-shell-channel kernel)
     (json-encode msg))
    (ein:kernel-set-callbacks-for-msg kernel msg-id callbacks)
    msg-id))


(defun ein:kernel-interrupt (kernel)
  (when (ein:$kernel-running kernel)
    (ein:log 'info "Interrupting kernel")
    (ein:query-singleton-ajax
     (list 'kernel-interrupt (ein:$kernel-kernel-id kernel))
     (ein:url (ein:$kernel-url-or-port kernel)
              (ein:$kernel-kernel-url kernel)
              "interrupt")
     :type "POST"
     :success (cons (lambda (&rest ignore)
                      (ein:log 'info "Sent interruption command."))
                    nil))))


(defun ein:kernel-kill (kernel &optional callback cbargs)
  (when (ein:$kernel-running kernel)
    (ein:query-singleton-ajax
     (list 'kernel-kill (ein:$kernel-kernel-id kernel))
     (ein:url (ein:$kernel-url-or-port kernel)
              (ein:$kernel-kernel-url kernel))
     :cache nil
     :type "DELETE"
     :success (cons (lambda (packed &rest ignore)
                      (ein:log 'info "Notebook kernel is killed")
                      (destructuring-bind (kernel callback cbargs)
                          packed
                        (setf (ein:$kernel-running kernel) nil)
                        (when callback (apply callback cbargs))))
                    (list kernel callback cbargs)))))


;; Reply handlers.

(defun ein:kernel-get-callbacks-for-msg (kernel msg-id)
  (gethash msg-id (ein:$kernel-msg-callbacks kernel)))

(defun ein:kernel-set-callbacks-for-msg (kernel msg-id callbacks)
  (puthash msg-id callbacks (ein:$kernel-msg-callbacks kernel)))

(defun ein:kernel--handle-shell-reply (kernel packet)
  (ein:log 'debug "KERNEL--HANDLE-SHELL-REPLY")
  (destructuring-bind
      (&key header content parent_header &allow-other-keys)
      (ein:json-read-from-string packet)
    (let* ((msg-type (plist-get header :msg_type))
           (msg-id (plist-get parent_header :msg_id))
           (callbacks (ein:kernel-get-callbacks-for-msg kernel msg-id))
           (cb (plist-get callbacks (intern (format ":%s" msg-type)))))
      (ein:log 'debug "KERNEL--HANDLE-SHELL-REPLY: msg_type = %s" msg-type)
      (if cb
          (ein:funcall-packed cb content)
        (ein:log 'debug "no callback for: msg_type=%s msg_id=%s"
                 msg-type msg-id))
      (ein:aif (plist-get content :payload)
          (ein:kernel--handle-payload kernel callbacks it))))
  (ein:log 'debug "KERNEL--HANDLE-SHELL-REPLY: finished"))

(defun ein:kernel--handle-payload (kernel callbacks payload)
  (loop with events = (ein:$kernel-events kernel)
        for p in payload
        for text = (plist-get p :text)
        for source = (plist-get p :source)
        if (equal source "IPython.zmq.page.page")
        do (when (not (equal (ein:trim text) ""))
             (ein:events-trigger
              events 'open_with_text.Pager (list :text text)))
        else if
        (equal source "IPython.zmq.zmqshell.ZMQInteractiveShell.set_next_input")
        do (let ((cb (plist-get callbacks :set_next_input)))
             (when cb (ein:funcall-packed cb text)))))

(defun ein:kernel--handle-iopub-reply (kernel packet)
  (ein:log 'debug "KERNEL--HANDLE-IOPUB-REPLY")
  (destructuring-bind
      (&key content parent_header header &allow-other-keys)
      (ein:json-read-from-string packet)
    (let* ((msg-type (plist-get header :msg_type))
           (callbacks (ein:kernel-get-callbacks-for-msg
                       kernel (plist-get parent_header :msg_id)))
           (events (ein:$kernel-events kernel)))
      (ein:log 'debug "KERNEL--HANDLE-IOPUB-REPLY: msg_type = %s" msg-type)
      (if (and (not (equal msg-type "status")) (null callbacks))
          (ein:log 'verbose "Got message not from this notebook.")
        (ein:case-equal msg-type
          (("stream" "display_data" "pyout" "pyerr")
           (ein:aif (plist-get callbacks :output)
               (ein:funcall-packed it msg-type content)))
          (("status")
           (ein:case-equal (plist-get content :execution_state)
             (("busy")
              (ein:events-trigger events 'status_busy.Kernel))
             (("idle")
              (ein:events-trigger events 'status_idle.Kernel))
             (("dead")
              (ein:kernel-stop-channels kernel)
              (ein:events-trigger events 'status_dead.Kernel))))
          (("clear_output")
           (ein:aif (plist-get callbacks :clear_output)
               (ein:funcall-packed it content)))))))
  (ein:log 'debug "KERNEL--HANDLE-IOPUB-REPLY: finished"))


;;; Utility functions

(defun ein:kernel-construct-defstring (content)
  "Construct call signature from CONTENT of ``:object_info_reply``.
Used in `ein:cell-finish-tooltip', etc."
  (or (plist-get content :call_def)
      (plist-get content :init_definition)
      (plist-get content :definition)))

(defun ein:kernel-construct-help-string (content)
  "Construct help string from CONTENT of ``:object_info_reply``.
Used in `ein:cell-finish-tooltip', etc."
  (ein:log 'debug "KERNEL-CONSTRUCT-HELP-STRING")
  (let* ((defstring (ein:aand
                     (ein:kernel-construct-defstring content)
                     (ansi-color-apply it)
                     (ein:string-fill-paragraph it)))
         (docstring (ein:aand
                     (or (plist-get content :call_docstring)
                         (plist-get content :init_docstring)
                         (plist-get content :docstring)
                         ;; "<empty docstring>"
                         )
                     (ansi-color-apply it)))
         (help (ein:aand
                (ein:filter 'identity (list defstring docstring))
                (ein:join-str "\n" it))))
    (ein:log 'debug "KERNEL-CONSTRUCT-HELP-STRING: help=%s" help)
    help))

(defun ein:kernel-request-stream (kernel code func &optional args)
  (ein:kernel-execute
   kernel
   code
   (list :output (cons (lambda (packed msg-type content)
                         (let ((func (car packed))
                               (args (cdr packed)))
                           (when (equal msg-type "stream")
                             (ein:aif (plist-get content :data)
                                 (apply func it args)))))
                       (cons func args)))))

(defun ein:kernel-sync-directory (kernel buffer)
  "Sync `default-directory' of BUFFER with cwd of KERNEL.
When no such directory exists, `default-directory' will not be changed."
  (ein:log 'info "Syncing directory of %s with kernel..." buffer)
  (ein:kernel-request-stream
   kernel
   "__import__('sys').stdout.write(__import__('os').getcwd())"
   (lambda (path buffer)
     (with-current-buffer buffer
       (if (file-accessible-directory-p path)
           (progn
             (setq default-directory path)
             (ein:log 'info
               "Syncing directory of %s with kernel...DONE (%s)"
               buffer path))
         (ein:log 'info
           "Syncing directory of %s with kernel...FAILED (no dir: %s)"
           buffer path))))
   (list buffer)))

(defun ein:kernelinfo-init (kernelinfo buffer)
  (setf (ein:$kernelinfo-buffer kernelinfo) buffer))

(defun ein:kernelinfo-setup-hooks (kernel)
  "Add `ein:kernelinfo-update-*' to `ein:$kernel-after-*-hook'."
  (push (cons #'ein:kernelinfo-update-all kernel)
        (ein:$kernel-after-start-hook kernel))
  (push (cons #'ein:kernelinfo-update-ccwd kernel)
        (ein:$kernel-after-execute-hook kernel)))

(defun ein:kernelinfo-update-all (kernel)
  (ein:log 'debug "EIN:KERNELINFO-UPDATE-ALL")
  (ein:log 'debug "(ein:kernel-live-p kernel) = %S"
           (ein:kernel-live-p kernel))
  (ein:kernelinfo-update-ccwd kernel)
  (ein:kernelinfo-update-hostname kernel))

(defun ein:kernelinfo-update-ccwd (kernel)
  (ein:kernel-request-stream
   kernel
   "__import__('sys').stdout.write(__import__('os').getcwd())"
   (lambda (cwd kernelinfo buffer)
     (setf (ein:$kernelinfo-ccwd kernelinfo) cwd)
     ;; sync buffer's `default-directory' with CWD
     (when (buffer-live-p buffer)
       (with-current-buffer buffer
         (when (file-accessible-directory-p cwd)
           (setq default-directory (file-name-as-directory cwd))))))
   (let ((kernelinfo (ein:$kernel-kernelinfo kernel)))
     (list kernelinfo (ein:$kernelinfo-buffer kernelinfo)))))

(defun ein:kernelinfo-update-hostname (kernel)
  (ein:kernel-request-stream
   kernel
   "__import__('sys').stdout.write(__import__('os').uname()[1])"
   (lambda (hostname kernelinfo)
     (setf (ein:$kernelinfo-hostname kernelinfo) hostname))
   (list (ein:$kernel-kernelinfo kernel))))

(provide 'ein-kernel)

;;; ein-kernel.el ends here
