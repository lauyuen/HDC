(yl-add-path "/lauyuen/vendor/warp")
(require 'warp)
(global-set-key (kbd "C-c C-w C-w") warp-mode) ;; Modify key bind as you want.

;; Set markdown converter (if you want)
(add-to-list 'warp-format-converter-alist
             '("\\.md\\|\\.markdown" t (lambda ()
                                         ;; Set command you are using
                                         '("markdown"))))

;; Below line is needed if you installed websocket npm module globally.
(setenv "NODE_PATH" "/path/to/global/node_modules")
;; or, if you have setup NODE_PATH in the shell
(setenv "NODE_PATH"
        (replace-regexp-in-string
         "\n+$" "" (shell-command-to-string "echo $NODE_PATH")))
