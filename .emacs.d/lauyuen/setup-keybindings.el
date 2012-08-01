(key-chord-mode 1)
(key-chord-define-global "gf" 'iy-go-to-char)
(key-chord-define-global "fd" 'iy-go-to-char-backward)
(key-chord-define-global "hj" 'ace-jump-mode)
(key-chord-define-global "jk" 'ace-jump-mode)

(require 'expand-region)
(key-chord-define-global "fj" 'er/expand-region)
(key-chord-define-global "gh" 'er/contract-region)

(require 'mark-more-like-this)
(key-chord-define-global "fn" 'mark-next-like-this)
(key-chord-define-global "fp" 'mark-previous-like-this)

(yl-add-path "/lauyuen/vendor/multiple-cursors.el")
(require 'multiple-cursors)
(key-chord-define-global "mc" 'mc/switch-from-mark-multiple-to-cursors)

(global-set-key (kbd "C-x f") 'recentf-open-files)
(global-set-key (kbd "M-?") 'ispell-word)
(define-key key-translation-map [?\C-h] [?\C-?])
(global-set-key (kbd "C-M-h") 'backward-kill-word)

(global-set-key (kbd "M-x") 'smex)
(key-chord-define-global "fh" 'hippie-expand)
(key-chord-define-global "u[" 'undo)
(key-chord-define-global "r[" 'undo-tree-redo)

(global-set-key (kbd "ESC <f4>") 'kill-emacs)
(global-set-key (kbd "<f2> s") 'shell)
(global-set-key (kbd "<f2> d") 'dired)
(global-set-key (kbd "<f2> g") 'magit-status)

(global-set-key (kbd "C-c n") 'cleanup-buffer)

