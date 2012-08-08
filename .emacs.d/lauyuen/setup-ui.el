(if (>= emacs-major-version 24) 
    (progn
      (add-to-list 'custom-theme-load-path
                   (concat user-emacs-directory "/lauyuen/vendor/themes"))
      (yl-add-path "/lauyuen/vendor/themes"))
  (progn
    (require 'color-theme)
    (add-to-list 'load-path (concat package-user-dir "/color-theme-twilight-0.1"))
    (autoload 'color-theme-twilight "color-theme-twilight" nil t)
    (color-theme-twilight)))


(setq scroll-margin 0
      scroll-conservatively 9001
      scroll-preserve-screen-position 1)

(fset 'yes-or-no-p 'y-or-n-p)

(global-undo-tree-mode)
(sml/setup)
(add-to-list 'sml/replacer-regexp-list '("^~/Notes/" ":Note:"))
(add-to-list 'sml/replacer-regexp-list '("^~/Dropbox/" ":DB:"))
(add-to-list 'sml/replacer-regexp-list '("^~/Dropbox/will" ":DB:will:")) 
(add-to-list 'sml/replacer-regexp-list '("^~/Dropbox/will/School/current" ":school:")) 

(global-rainbow-delimiters-mode 1)

(yl-add-path "/lauyuen/vendor/hardcore-mode.el")
(add-to-list 'default-frame-alist '(font . "Inconsolata-10"))

; ---------------------------------------------------[ Extras External Goodies ]
(setq too-hardcore-backspace nil)
(setq too-hardcore-return t)
(require 'hardcore-mode)
(global-hardcore-mode)

(yl-add-path "/lauyuen/vendor/pretty-mode")
(require 'pretty-mode)

(require 'sudo-ext)
(global-hl-line-mode)

