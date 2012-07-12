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
