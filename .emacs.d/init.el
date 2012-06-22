;;
;; File:    ~/.emacs
;; Author:  Yuen Lau
;; Version: 2
;; OS:      Arch, Mint Debian, Snow Leopard, Windows 7
;; LMD:     Wed Oct 27 00:49:12 EDT 2010
;;

(dolist (mode '(menu-bar-mode tool-bar-mode scroll-bar-mode blink-cursor-mode))
  (when (fboundp mode) (funcall mode -1)))
(setq initial-scratch-message nil
      inhibit-startup-screen t)
;;
;; Package Loading
;;
(require 'package)
(add-to-list 'package-archives
             '("marmalade" . "http://marmalade-repo.org/packages/") t)
(package-initialize)
(when (not package-archive-contents)
  (package-refresh-contents))
(defvar my-packages '(paredit twilight-theme smex
                              php-mode))
(dolist (p my-packages)
  (when (not (package-installed-p p))
    (package-install p)))
(load-theme 'twilight t)

(progn
  (setq yld-system-config (concat user-emacs-directory system-name ".el")
        yld-user-config (concat user-emacs-directory user-login-name ".el")
        yld-user-dir (concat user-emacs-directory user-login-name))

  (setq smex-save-file (concat user-emacs-directory ".smex-items"))
  (smex-initialize)
  (global-set-key (kbd "M-x") 'smex)

  (defun yld-eval-after-init (form)
    (let ((func (list 'lambda nil form)))
      (add-hook 'after-init-hook func)
      (when after-init-time
        (eval form))))

  (yld-eval-after-init
   '(progn
      (when (file-exists-p yld-system-config) (load yld-system-config))
      (when (file-exists-p yld-user-config) (load yld-user-config))
      (when (file-exists-p yld-user-dir)
        (mapc 'load (directory-files yld-user-dir t "^[^#].*el$"))))))

(defun yld-add-path (p)
  (add-to-list 'load-path (concat user-emacs-directory p)))

;;
;; Custom Variables
;;
(custom-set-variables
 '(custom-safe-themes (quote ("6cfe5b2f818c7b52723f3e121d1157cf9d95ed8923dbc1b47f392da80ef7495d" default)))

 '(column-number-mode t)
 '(display-battery-mode t)
 '(display-time-mode t)
 '(display-battery-mode t)

 '(indicate-buffer-boundaries (quote ((t . right) (top . left))))
 '(indicate-empty-lines t)
 '(uniquify-buffer-name-style (quote forward) nil (uniquify))

 '(c-default-style "bsd")
 '(c-basic-offset 4)
 '(save-place t nil (saveplace))

 '(show-paren-mode t)
 '(transient-mark-mode t)
 '(indent-tabs-mode nil)
 '(delete-selection-mode t)
 '(ido-mode 'buffer)
 '(recentf-mode t)
 )

;; Emacs server
(when '(server-running-p)
  (message "Server Already Running ..."))

(setq backup-directory-alist
      `((".*" . ,temporary-file-directory)))
(setq auto-save-file-name-transforms
      `((".*" ,temporary-file-directory t)))
