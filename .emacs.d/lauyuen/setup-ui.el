(if (>= emacs-major-version 24) 
    (progn
      (load-theme 'twilight t))
  (progn
    (require 'color-theme)
    (add-to-list 'load-path (concat package-user-dir "/color-theme-twilight-0.1"))
    (autoload 'color-theme-twilight "color-theme-twilight" nil t)
    (color-theme-twilight)
    ))

(custom-set-faces
 '(org-hide ((t (:foreground "black")))))

(yl-add-path "/lauyuen/vendors/pretty-mode")
(require 'pretty-mode)

(fset 'yes-or-no-p 'y-or-n-p)

(global-undo-tree-mode)

(sml/setup)
(custom-set-variables
 '(sml/hidden-modes (quote ("AC" "yas" "hc" "Undo-Tree" "hl-p")))
 '(sml/inactive-background-color "color-234")
 '(sml/active-background-color "color-16")
 '(sml/show-battery nil)
 '(sml/show-time t))

(add-to-list 'sml/replacer-regexp-list '("^~/Notes/" ":Note:"))
(add-to-list 'sml/replacer-regexp-list '("^~/Dropbox/" ":DB:"))
(add-to-list 'sml/replacer-regexp-list '("^:DB:will" ":will:")) 
(add-to-list 'sml/replacer-regexp-list '("^:will:School/current" ":school:")) 


(global-rainbow-delimiters-mode 1)

(yl-add-path "/lauyuen/vendors/hardcore-mode.el")
(yl-add-path "/lauyuen/vendors/multiple-cursorse.el")

(setq too-hardcore-backspace nil)
(setq too-hardcore-return t)
(require 'hardcore-mode)
(global-hardcore-mode)

(require 'sudo-ext)
(global-hl-line-mode)
