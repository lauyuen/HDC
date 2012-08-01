;;; ein-connect.el --- Connect external buffers to IPython

;; Copyright (C) 2012- Takafumi Arakaki

;; Author: Takafumi Arakaki <aka.tkf at gmail.com>

;; This file is NOT part of GNU Emacs.

;; ein-connect.el is free software: you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; ein-connect.el is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with ein-connect.el.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;; FIXME: There is a problem when connected notebook is closed.
;;        This can be fixed in some ways:
;; * Turn off ein:connect when the command that uses kernel is invoked
;;   but corresponding notebook was closed already.
;; * Connect directly to ein:kernel and make its destructor to care
;;   about connecting buffers.

;;; Code:

(require 'eieio)
(eval-when-compile (require 'auto-complete nil t))

(require 'ein-notebook)
(require 'ein-shared-output)

(declare-function ein:notebooklist-list-notebooks "ein-notebooklist")
(declare-function ein:notebooklist-open-notebook-global "ein-notebooklist")


;;; Utils

(defun ein:maybe-save-buffer (option)
  "Conditionally save current buffer.
Return `t' if the buffer is unmodified or `nil' otherwise.
If the buffer is modified, buffer is saved depending on the value
of OPTION:
  ask  : Ask whether the buffer should be saved.
  yes  : Save buffer always.
  no   : Do not save buffer."
  (if (not (buffer-modified-p))
      t
    (case option
      (ask (when (y-or-n-p "Save buffer? ")
             (save-buffer)
             t))
      (yes (save-buffer)
           t)
      (t nil))))


;;; Variable/class

(defcustom ein:connect-run-command "%run -n"
  "``%run`` magic command used for `ein:connect-run-buffer'.
Types same as `ein:notebook-console-security-dir' are valid."
  :type '(choice
          (string :tag "command" "%run")
          (alist :tag "command mapping"
                 :key-type (choice :tag "URL or PORT"
                                   (string :tag "URL" "http://127.0.0.1:8888")
                                   (integer :tag "PORT" 8888)
                                   (const default))
                 :value-type (string :tag "command" "%run"))
          (function :tag "command getter"
                    (lambda (url-or-port) (format "%%run -n -i -t -d"))))
  :group 'ein)

(defun ein:connect-run-command-get ()
  (ein:choose-setting 'ein:connect-run-command
                      (ein:$notebook-url-or-port (ein:connect-get-notebook))))

(defcustom ein:connect-save-before-run 'yes
  "Whether the buffer should be saved before `ein:connect-run-buffer'."
  :type '(choice (const :tag "Always save buffer" yes)
                 (const :tag "Always do not save buffer" no)
                 (const :tag "Ask" ask))
  :group 'ein)

(ein:deflocal ein:@connect nil
  "Buffer local variable to store an instance of `ein:$connect'")

(defclass ein:$connect ()
  ((notebook :initarg :notebook :type ein:$notebook)
   (buffer :initarg :buffer :type buffer)))

(defun ein:connect-setup (notebook buffer)
  (with-current-buffer buffer
    (setq ein:@connect
          (ein:$connect "Connect" :notebook notebook :buffer buffer))
    ein:@connect))


;;; Methods

(defun ein:connect-to-notebook (nbpath)
  "Connect any buffer to notebook and its kernel."
  (interactive
   (list
    (completing-read
     "Notebook to connect [URL-OR-PORT/NAME]: "
     (ein:notebooklist-list-notebooks))))
  (ein:notebooklist-open-notebook-global
   nbpath
   (lambda (notebook -ignore- buffer)
     (ein:connect-buffer-to-notebook notebook buffer))
   (list (current-buffer))))

(defun ein:connect-to-notebook-buffer (buffer-or-name)
  "Connect any buffer to opened notebook and its kernel."
  (interactive
   (list
    (completing-read
     "Notebook buffer to connect: "
     (mapcar #'buffer-name (ein:notebook-opened-buffers)))))
  (let ((notebook
         (buffer-local-value 'ein:notebook (get-buffer buffer-or-name))))
    (ein:connect-buffer-to-notebook notebook)))

(defun ein:connect-buffer-to-notebook (notebook &optional buffer)
  "Connect BUFFER to NOTEBOOK."
  (unless buffer
    (setq buffer (current-buffer)))
  (let ((connection (ein:connect-setup notebook buffer)))
    (when (ein:eval-if-bound 'ac-sources)
      (push 'ac-source-ein-cached ac-sources))
    (with-current-buffer buffer
      (ein:connect-mode))
    (ein:log 'info "Connected to %s"
             (ein:$notebook-notebook-name notebook))
    connection))

(defun ein:connect-get-notebook ()
  (oref ein:@connect :notebook))

(defun ein:connect-get-kernel ()
  (ein:$notebook-kernel (ein:connect-get-notebook)))

(defun ein:connect-eval-buffer ()
  "Evaluate the whole buffer.  Note that this will run the code
inside the ``if __name__ == \"__main__\":`` block."
  (interactive)
  (ein:connect-eval-string-internal (buffer-string))
  (ein:log 'info "Whole buffer is sent to the kernel."))

(defun ein:connect-run-buffer (&optional ask-command)
  "Run buffer using ``%run``.  Ask for command if the prefix ``C-u`` is given.
Variable `ein:connect-run-command' sets the default command."
  (interactive "P")
  ;; FIXME: this should be more intelligent than just `buffer-file-name'
  ;;        to support connecting IPython over ssh.
  (ein:aif (buffer-file-name)
      (let* ((default-command (ein:connect-run-command-get))
             (command (if ask-command
                          (read-from-minibuffer "Command: " default-command)
                        default-command))
             (cmd (format "%s %s" command it)))
        (if (ein:maybe-save-buffer ein:connect-save-before-run)
            (progn
              (ein:connect-eval-string-internal cmd)
              (ein:log 'info "Command sent to the kernel: %s" cmd))
          (ein:log 'info "Buffer must be saved before %%run.")))
    (error (concat "This buffer has no associated file.  "
                   "Use `ein:connect-eval-buffer' instead."))))

(defun ein:connect-run-or-eval-buffer (&optional eval)
  "Run buffer using the ``%run`` magic command or eval whole
buffer if the prefix ``C-u`` is given.
Variable `ein:connect-run-command' sets the command to run.
You can change the command and/or set the options.
See also: `ein:connect-run-buffer', `ein:connect-eval-buffer'."
  (interactive "P")
  (if eval
      (ein:connect-eval-buffer)
    (ein:connect-run-buffer)))

(defun ein:connect-eval-region (start end)
  (interactive "r")
  (ein:connect-eval-string-internal (buffer-substring start end))
  (ein:log 'info "Selected region is sent to the kernel."))

(defun ein:connect-eval-string (code)
  (interactive "sIP[y]: ")
  (ein:connect-eval-string-internal code)
  (ein:log 'info "Code \"%s\" is sent to the kernel." code))

(defun ein:connect-eval-string-internal (code)
  (let ((cell (ein:shared-output-get-cell))
        (kernel (ein:connect-get-kernel))
        (code (ein:trim-indent code)))
    (ein:cell-execute cell kernel code)))

(defun ein:connect-request-tool-tip-command ()
  (interactive)
  (let ((notebook (ein:connect-get-notebook)))
    (ein:kernel-if-ready (ein:$notebook-kernel notebook)
      (let ((func (ein:object-at-point)))
        ;; Set cell=nil.  In fact, the argument cell is not used.
        ;; FIXME: refactor `ein:notebook-request-tool-tip'
        (ein:notebook-request-tool-tip notebook nil func)))))

(defun ein:connect-request-help-command ()
  (interactive)
  (ein:notebook-request-help (ein:connect-get-notebook)))

(defun ein:connect-request-tool-tip-or-help-command (&optional pager)
  (interactive "P")
  (if pager
      (ein:connect-request-help-command)
    (ein:connect-request-tool-tip-command)))

(defun ein:connect-complete-command ()
  (interactive)
  (ein:notebook-complete-at-point (ein:connect-get-notebook)))

(defun ein:connect-pop-to-notebook ()
  (interactive)
  (pop-to-buffer (ein:notebook-buffer (ein:connect-get-notebook))))


;;; ein:connect-mode

(defvar ein:connect-mode-map (make-sparse-keymap))

(let ((map ein:connect-mode-map))
  (define-key map "\C-c\C-c" 'ein:connect-run-or-eval-buffer)
  (define-key map "\C-c\C-r" 'ein:connect-eval-region)
  (define-key map (kbd "C-:") 'ein:connect-eval-string)
  (define-key map "\C-c\C-f" 'ein:connect-request-tool-tip-or-help-command)
  (define-key map "\C-c\C-i" 'ein:connect-complete-command)
  (define-key map "\C-c\C-z" 'ein:connect-pop-to-notebook)
  (define-key map "\M-."          'ein:pytools-jump-to-source-command)
  (define-key map (kbd "C-c C-.") 'ein:pytools-jump-to-source-command)
  (define-key map "\M-,"          'ein:pytools-jump-back-command)
  (define-key map (kbd "C-c C-,") 'ein:pytools-jump-back-command)
  map)

(define-minor-mode ein:connect-mode
  "Minor mode for communicating with IPython notebook.

\\{ein:connect-mode-map}"
  :lighter " ein:c"
  :keymap ein:connect-mode-map
  :group 'ein)


(provide 'ein-connect)

;;; ein-connect.el ends here
