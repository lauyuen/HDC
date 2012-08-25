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
 '(custom-safe-themes (quote ("78c0aa2b09af1fbec5b20a17c7bd1106cd649acd112be7a16d76d163d50a7690" "b957de713a7dbaedfdf7b7d4f23ef71f009f2b22b02639044834515cd2b6165c" "9eb1393d05d52ea668a417f322574b303b5e7679d65307ad559752f06fbde7a0" "9dc319926ac4946719dd3389807bbd87610501098028ef727a425bf0bfc35fcb" "f38dd27d6462c0dac285aa95ae28aeb7df7e545f8930688c18960aeaf4e807ed" "27b53b2085c977a8919f25a3a76e013ef443362d887d52eaa7121e6f92434972" "159bb8f86836ea30261ece64ac695dc490e871d57107016c09f286146f0dae64" "470e7c84ff1606b88b46620fcc839d87d9f0c1a4b2eb9f2b0ac5dfaeca1dbab4" "fca8ce385e5424064320d2790297f735ecfde494674193b061b9ac371526d059" default)))
 '(delete-selection-mode t)
 '(display-time-mode t)
 '(fill-column 80)
 '(global-hl-line-mode t)
 '(ido-enable-flex-matching t)
 '(indent-tabs-mode nil)
 '(indicate-buffer-boundaries (quote ((t . right) (top . left))))
 '(indicate-empty-lines t)
 '(inhibit-startup-echo-area-message "lauyuen")
 '(minibuffer-prompt-properties (quote (read-only t point-entered minibuffer-avoid-prompt face minibuffer-prompt)))
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
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(mode-line ((t (:background "color-16" :foreground "gray60" :box (:line-width -1 :color "SystemHotTrackingColor")))))
 '(mode-line-highlight ((t (:box nil))))
 '(whitespace-space ((t (:background "background" :foreground "#2a3441"))) t))
