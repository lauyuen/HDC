(progn
  (setq smex-save-file (concat user-emacs-directory ".smex-items"))
  (smex-initialize)
  (global-set-key (kbd "M-x") 'smex))

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
 '(ansi-color-names-vector ["#FFFFFF" "#d15120" "#5f9411" "#d2ad00" "#6b82a7" "#a66bab" "#6b82a7" "#505050"])
 '(browse-url-text-browser "google-chrome")
 '(c-basic-offset 4)
 '(c-default-style "bsd")
 '(column-number-mode t)
 '(custom-safe-themes (quote ("79339b88d1813aa3aee5862e18eae58b6bac67b93cde2c7199892c1cab87eb4f" "e9f5505ca13ffd8df41d0654952e23be7ec31d5db2de3015270b91e3829b5525" "fca8ce385e5424064320d2790297f735ecfde494674193b061b9ac371526d059" "6cfe5b2f818c7b52723f3e121d1157cf9d95ed8923dbc1b47f392da80ef7495d" default)))
 '(delete-selection-mode t)
 '(display-time-mode t)
 '(fci-rule-character-color "#d9d9d9")
 '(fci-rule-color "#d9d9d9")
 '(fill-column 80)
 '(ido-enable-flex-matching t)
 '(indent-tabs-mode nil)
 '(indicate-buffer-boundaries (quote ((t . right) (top . left))))
 '(indicate-empty-lines t)
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
 '(uniquify-buffer-name-style (quote forward) nil (uniquify)))

(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(diff-added ((t (:inherit diff-changed :background "#113311"))))
 '(diff-file-header ((t (:background "color-232" :weight bold))))
 '(diff-header ((t (:background "color-232"))))
 '(diff-removed ((t (:inherit diff-changed :background "#331111"))))
 '(hl-line ((t (:inherit highlight))))
 '(mm/master-face ((t (:inherit text-cursor))))
 '(mm/mirror-face ((t (:inherit text-cursor))))
 '(org-hide ((t (:foreground "black"))))
 '(show-paren-match ((t (:background "color-22"))))
 '(show-paren-mismatch ((t (:background "color-53" :foreground "white"))))
 '(sml/filename ((t (:inherit sml/global :foreground "color-119"))))
 '(sml/prefix ((t (:inherit sml/global :foreground "color-57"))))
 '(writegood-duplicates-face ((t (:background "black" :foreground "color-131"))))
 '(writegood-passive-voice-face ((t (:background "black" :foreground "color-131"))))
 '(writegood-weasels-face ((t (:background "black" :foreground "color-131"))))
 '(yas/field-highlight-face ((t (:background "color-232")))))
