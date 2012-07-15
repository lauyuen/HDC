(key-chord-mode 1)
(key-chord-define-global "gf" 'iy-go-to-char)
(key-chord-define-global "fd" 'iy-go-to-char-backward)
(key-chord-define-global "hj" 'ace-jump-mode)
(key-chord-define-global "jk" 'ace-jump-mode)

(global-set-key (kbd "C-x f") 'recentf-open-files)
(define-key key-translation-map [?\C-h] [?\C-?])
