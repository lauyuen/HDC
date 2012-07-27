(key-chord-mode 1)
(key-chord-define-global "gf" 'iy-go-to-char)
(key-chord-define-global "fd" 'iy-go-to-char-backward)
(key-chord-define-global "hj" 'ace-jump-mode)
(key-chord-define-global "jk" 'ace-jump-mode)

(require 'mark-more-like-this)
(key-chord-define-global "fn" 'mark-next-like-this)
(key-chord-define-global "fp" 'mark-previous-like-this)
;(key-chord-define-global "fj" ')


(global-set-key (kbd "C-x f") 'recentf-open-files)
(global-set-key (kbd "M-?") 'ispell-word)
(define-key key-translation-map [?\C-h] [?\C-?])
