;;
;; File:    ~/.emacs
;; Author:  Yuen Lau
;; Version: 2
;; OS:      Arch, Mint Debian, Snow Leopard, Windows 7
;; LMD:     Wed Oct 27 00:49:12 EDT 2010
;;


(if window-system
    (progn
      (set-face-attribute 'default nil :height 90))
  (dolist (mode '(menu-bar-mode tool-bar-mode scroll-bar-mode blink-cursor-mode))
    (when (fboundp mode) (funcall mode -1))))

(setq initial-scratch-message nil
      inhibit-startup-screen t)
;;
;; Package Loading
;;

(defvar yl-bad-packages '())
(if (>= emacs-major-version 24) 
    (progn
      (add-to-list 'load-path "~/.emacs.d/emacs24/")
      (add-to-list 'yl-bad-packages 
                   '((color-theme  nil)
                     (color-theme-twilight nil)
                     (json nil))))
  (progn
    (add-to-list 'load-path "~/.emacs.d/emacs23/")
    (add-to-list 'yl-bad-packages 
                 '((twilight-theme nil)))))


(progn
  (require 'package)
  (add-to-list 'package-archives
               '("marmalade" . "http://marmalade-repo.org/packages/") t)
  (add-to-list 'package-archives
               '("melpa" . "http://melpa.milkbox.net/packages/") t)

  (setq package-load-list (cons 'all (car yl-bad-packages)))

  
  (package-initialize)
  (when (not package-archive-contents)
    (package-refresh-contents))
  (defvar my-packages '(paredit smex php-mode))
  (dolist (p my-packages)
    (when (not (package-installed-p p))
      (package-install p)))
  (setq smex-save-file (concat user-emacs-directory ".smex-items"))
  (smex-initialize)
  (global-set-key (kbd "M-x") 'smex)
  
  (require 'mark-more-like-this)
  (global-set-key (kbd "C-<") 'mark-previous-like-this)
  (global-set-key (kbd "C->") 'mark-next-like-this))

(progn
  (setq yld-system-config (concat user-emacs-directory system-name ".el")
        yld-user-config (concat user-emacs-directory user-login-name ".el")
        yld-user-dir (concat user-emacs-directory user-login-name))

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

(defun yl-add-path (p)
  (add-to-list 'load-path (concat user-emacs-directory p)))

;;
;; Custom Variables
;;
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
 '(c-basic-offset 4)
 '(c-default-style "bsd")
 '(column-number-mode t)
 '(delete-selection-mode t)
 '(display-time-mode t)
 '(ido-enable-flex-matching t)
 '(indent-tabs-mode nil)
 '(indicate-buffer-boundaries (quote ((t . right) (top . left))))
 '(indicate-empty-lines t)
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

;; Emacs server
(require 'server)
(when (and (functionp 'server-running-p) (not (server-running-p)))
  (server-start))

(setq backup-directory-alist
      `((".*" . ,temporary-file-directory)))
(setq auto-save-file-name-transforms
      `((".*" ,temporary-file-directory t)))

(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(org-hide ((t (:foreground "black"))))
 '(sml/filename ((t (:inherit sml/global :foreground "color-119"))))
 '(sml/prefix ((t (:inherit sml/global :foreground "color-57"))))
 '(writegood-duplicates-face ((t (:background "black" :foreground "color-131"))))
 '(writegood-passive-voice-face ((t (:background "black" :foreground "color-131"))))
 '(writegood-weasels-face ((t (:background "black" :foreground "color-131")))))

