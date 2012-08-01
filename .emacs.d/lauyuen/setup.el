(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(TeX-PDF-mode t)
 '(TeX-source-correlate-method (quote synctex))
 '(TeX-source-correlate-mode t)
 '(TeX-source-correlate-start-server t)
 '(TeX-view-program-list (quote (("Okular" "okular --unique %o#src:%n%b"))))
 '(TeX-view-program-selection (quote ((output-pdf "Okular") (output-dvi "xdvi") (output-pdf "xpdf") (output-html "xdg-open"))))
 '(browse-url-text-browser "google-chrome")
 '(c-basic-offset 4)
 '(c-default-style (quote ((c-mode . "bsd") (java-mode . "bsd"))))
 '(column-number-mode t)
 '(confirm-nonexistent-file-or-buffer nil)
 '(custom-safe-themes (quote ("159bb8f86836ea30261ece64ac695dc490e871d57107016c09f286146f0dae64" "470e7c84ff1606b88b46620fcc839d87d9f0c1a4b2eb9f2b0ac5dfaeca1dbab4" "fca8ce385e5424064320d2790297f735ecfde494674193b061b9ac371526d059" default)))
 '(delete-by-moving-to-trash t)
 '(delete-selection-mode t)
 '(display-time-mode t)
 '(fill-column 80)
 '(global-hl-line-mode t)
 '(ido-enable-flex-matching t)
 '(indent-tabs-mode nil)
 '(indicate-buffer-boundaries (quote ((t . right) (top . left))))
 '(indicate-empty-lines t)
 '(inhibit-startup-echo-area-message "lauyuen")
 '(python-shell-interpreter "ipython")
 '(python-shell-interpreter-args "")
 '(recentf-mode t)
 '(safe-local-variable-values (quote ((time-stamp-active . t))))
 '(save-place t nil (saveplace))
 '(show-paren-mode t)
 '(sml/active-background-color "color-16")
 '(sml/hidden-modes (quote ("AC" "yas" "hc" "Undo-Tree" "hl-p")))
 '(sml/inactive-background-color "color-234")
 '(sml/show-battery nil)
 '(sml/show-time t)
 '(transient-mark-mode t)
 '(uniquify-buffer-name-style (quote forward) nil (uniquify))
 '(volatile-highlights-mode t))


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
  (save-excursion (untabify (point-min) (point-max))))

(defun indent-buffer ()
  "Indent the current buffer"
  (interactive)
  (save-excursion (indent-region (point-min) (point-max) nil)))

(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(hl-line ((t nil))))
