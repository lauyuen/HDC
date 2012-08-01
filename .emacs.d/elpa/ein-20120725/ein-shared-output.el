;;; ein-shared-output.el --- Output buffer for ein-connect.el

;; Copyright (C) 2012- Takafumi Arakaki

;; Author: Takafumi Arakaki <aka.tkf at gmail.com>

;; This file is NOT part of GNU Emacs.

;; ein-shared-output.el is free software: you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; ein-shared-output.el is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with ein-shared-output.el.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;; When executing code from outside of notebook, some place for output
;; is needed.  This module buffer containing one special cell for that
;; purpose.

;;; Code:

(eval-when-compile (require 'cl))
(require 'eieio)

(require 'ein-cell)


;;; Classes and variables

(defclass ein:shared-output-cell (ein:codecell)
  ((cell-type :initarg :cell-type :initform "shared-output")
   ;; (element-names :initform (:prompt :output :footer))
   (popup :initarg :popup :initform nil :type boolean)
   )
  "A singleton cell to show output from non-notebook buffers.")

(defclass ein:$shared-output ()
  ((cell :initarg :cell :type ein:shared-output-cell)
   (events :initarg :events :type ein:events)
   (ewoc :initarg :ewoc :type ewoc)))

(defvar ein:@shared-output nil
  "Hold an instance of `ein:$shared-output'.")

(defconst ein:shared-output-buffer-name "*ein:shared-output*")


;;; Cell related

(defmethod ein:cell-execute ((cell ein:shared-output-cell) kernel code
                             &optional popup)
  (oset cell :popup popup)
  (oset cell :kernel kernel)
  (ein:cell-execute-internal cell kernel code :silent nil))

(defmethod ein:cell--handle-output ((cell ein:shared-output-cell)
                                    msg-type content)
  (ein:log 'info "Got output '%s' in the shared buffer." msg-type)
  (when (oref cell :popup)
    (pop-to-buffer (ein:shared-output-create-buffer)))
  (call-next-method))


;;; Main

(defun ein:shared-output-create-buffer ()
  "Get or create the shared output buffer."
  (get-buffer-create ein:shared-output-buffer-name))

(defun ein:shared-output-buffer ()
  "Get the buffer associated with `ein:@shared-output'."
  (ewoc-buffer (oref ein:@shared-output :ewoc)))

(defun ein:shared-output-healthy-p ()
  (and (ein:$shared-output-p ein:@shared-output)
       (buffer-live-p (ein:shared-output-buffer))))

(defun ein:shared-output-get-or-create ()
  (if (ein:shared-output-healthy-p)
      ein:@shared-output
    (with-current-buffer (ein:shared-output-create-buffer)
      ;; FIXME: This is a duplication of `ein:notebook-from-json'.
      ;;        Must be merged.
      (let* ((inhibit-read-only t)
             ;; Enable nonsep for ewoc object (the last argument is non-nil).
             ;; This is for putting read-only text properties to the newlines.
             ;; FIXME: Do not depend on `ein:notebook-pp'!
             (ewoc (ewoc-create 'ein:notebook-pp
                                (ein:propertize-read-only "\n")
                                nil t))
             (events (ein:events-new (current-buffer)))
             (cell (ein:shared-output-cell "SharedOutputCell"
                                           :ewoc ewoc
                                           :events events)))
        (erase-buffer)
        (ein:shared-output-bind-events events)
        (setq ein:@shared-output
              (ein:$shared-output "SharedOutput" :ewoc ewoc :cell cell
                                  :events events))
        (ein:cell-enter-last cell))
      (setq buffer-read-only t)
      (ein:shared-output-mode)
      ein:@shared-output)))

(defun ein:shared-output-bind-events (events)
  "Add dummy event handlers."
  (ein:events-on events 'set_dirty.Notebook (lambda (&rest ignore)))
  (ein:events-on events 'maybe_reset_undo.Notebook (lambda (&rest ignore))))

(defun ein:shared-output-get-cell ()
  "Get the singleton shared output cell.
Create a cell if the buffer has none."
  (oref (ein:shared-output-get-or-create) :cell))

(defun ein:shared-output-get-kernel ()
  (let ((cell (ein:shared-output-get-cell)))
    (when (slot-boundp cell :kernel)
      (oref cell :kernel))))

(defun ein:shared-output-pop-to-buffer ()
  "Open shared output buffer."
  (interactive)
  (ein:shared-output-get-or-create)
  (pop-to-buffer (ein:shared-output-create-buffer)))

(defmethod ein:shared-output-show-code-cell ((cell ein:codecell))
  "Show code CELL in shared-output buffer.
Note that this function assumed to be called in the buffer
where CELL locates."
  (let ((new (ein:cell-convert cell "shared-output")))
    ;; Make sure `ein:@shared-output' is initialized:
    (ein:shared-output-get-or-create)
    (with-current-buffer (ein:shared-output-create-buffer)
      (let ((inhibit-read-only t)
            (ein:cell-max-num-outputs nil))
        (oset new :ewoc (oref ein:@shared-output :ewoc))
        (oset new :events (oref ein:@shared-output :events))
        (erase-buffer)  ; because there are only one cell anyway
        (oset ein:@shared-output :cell new)
        (ein:cell-enter-last new)
        (pop-to-buffer (current-buffer))))))


;;; ein:shared-output-mode

(define-derived-mode ein:shared-output-mode fundamental-mode "ein:so"
  "Shared output mode."
  (font-lock-mode))

(let ((map ein:shared-output-mode-map))
  (define-key map "\M-."          'ein:pytools-jump-to-source-command)
  (define-key map (kbd "C-c C-.") 'ein:pytools-jump-to-source-command)
  (define-key map "q" 'bury-buffer))

(add-hook 'ein:shared-output-mode-hook 'ein:truncate-lines-on)


(provide 'ein-shared-output)

;;; ein-shared-output.el ends here
