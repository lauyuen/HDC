(defun cleanup-buffer-safe ()
  "Perform a bunch of safe operations on the whitespace content of a buffer.
Does not indent buffer, because it is used for a before-save-hook, and that
might be bad."
  (interactive)
  (untabify-buffer)
  (delete-trailing-whitespace)
  (set-buffer-file-coding-system 'utf-8))

(defun cleanup-buffer ()
  "Perform a bunch of operations on the whitespace content of a buffer.
Including indent-buffer, which should not be called automatically on save."
  (interactive)
  (cleanup-buffer-safe)
  (indent-buffer))

(defun untabify-buffer ()
    "Untabify current buffer"
    (interactive)
    (save-excursion (untabify (point-min) (point-max)))
)

(defun indent-buffer ()
    "Indent the current buffer"
    (interactive)
    (save-excursion (indent-region (point-min) (point-max) nil))
)

(global-set-key (kbd "C-c n") 'cleanup-buffer)
