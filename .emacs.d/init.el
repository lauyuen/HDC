;; File:      ~/.emacs.d/init.el
;; Author:    Yuen Lau
;; Version:   2
;; OS:        Arch, Debian, Mint Debian, Snow Leopard, Lion, Windows 7
;; Time-stamp: <2012-08-14 15:20 (lauyuen)>
; ----------------------------------------------------------[ Software Licence ]
;; Copyright (c) Yuen Lau <hello@yuen-lau.com> 2010-2012
;; All rights reserved.
;;
;; Redistribution and use in source and binary forms, with or without
;; modification, are permitted provided that the following conditions
;; are met:
;; 1. Redistributions of source code must retain the above copyright
;;    notice, this list of conditions and the following disclaimer.
;; 2. Redistributions in binary form must reproduce the above copyright
;;    notice, this list of conditions and the following disclaimer in the
;;    documentation and/or other materials provided with the distribution.
;; 3. Neither the name of the University nor the names of its contributors
;;    may be used to endorse or promote products derived from this software
;;    without specific prior written permission.
;;
;; THIS SOFTWARE IS PROVIDED BY THE REGENTS AND CONTRIBUTORS ``AS IS'' AND
;; ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
;; IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
;; ARE DISCLAIMED.  IN NO EVENT SHALL THE REGENTS OR CONTRIBUTORS BE LIABLE
;; FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
;; DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
;; OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
;; HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
;; LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
;; OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
;; SUCH DAMAGE.
;;
; ---------------------------------------------------------------[ Quick Guide ]
;; Everywhere with a comment explaining what the function does or what the 
;; variable is should mean that it is safe to tweak and/or hack.
;;
;; Have fun.
;;
(require 'cl)
; ----------------------------------------------[ Minial interface in terminal ]
(dolist (mode '(tool-bar-mode scroll-bar-mode blink-cursor-mode))
  (when (fboundp mode) (funcall mode -1)))
(if window-system
    (set-face-attribute 'default nil :height 90)
  (if (fboundp 'menu-bar-mode) (menu-bar-mode -1)))
(setf initial-scratch-message nil
      inhibit-startup-screen t)

; ---------------------------------------------------------------[ System Type ]
(defvar system-type-as-string (prin1-to-string system-type))
(defvar on_windows_nt (string-match "windows-nt" system-type-as-string))
(defvar on_darwin     (string-match "darwin" system-type-as-string))
(defvar on_gnu_linux  (string-match "gnu/linux" system-type-as-string))
(defvar on_cygwin     (string-match "cygwin" system-type-as-string))
(defvar on_solaris    (string-match "usg-unix-v" system-type-as-string))


; -----------------------------------------------------------[ Package Loading ]
;; Don't load incompatible packages.
(defvar yl-bad-packages '())
(if (>= emacs-major-version 24) 
    (progn
      (add-to-list 'load-path "~/.emacs.d/emacs24/")
      (add-to-list 'yl-bad-packages '(
                                      (color-theme  nil)
                                      (color-theme-twilight nil)
                                      (json nil)
                                      )))
  (progn
    (add-to-list 'load-path "~/.emacs.d/emacs23/")
    (add-to-list 'yl-bad-packages '(
                                    (twilight-theme nil)
                                    (twilight-bright-theme nil)
                                    ))))
(progn
  (require 'package)
  ;; Using marmalade and melpa repositories.
  (add-to-list 'package-archives
               '("marmalade" . "http://marmalade-repo.org/packages/") t)
  (add-to-list 'package-archives
               '("melpa" . "http://melpa.milkbox.net/packages/") t)
  (setf package-load-list (cons 'all (car yl-bad-packages)))
  (package-initialize)
  (when (not package-archive-contents)
    (package-refresh-contents))
  ;; List of packages nto always retrieve. 
  (setf my-packages '(
                      ace-jump-mode
                      apache-mode
                      auto-complete
;;                    color-theme
;;                    color-theme-twilight
                      csharp-mode
                      helm
                      iy-go-to-char
                      json
                      key-chord
                      less-css-mode
                      magit
                      magithub
                      mark-more-like-this
                      mark-multiple
                      mmm-mode
                      multi-term
                      paredit
                      php-mode
                      popup
                      rainbow-delimiters
                      rainbow-mode
                      smex
;;                    twilight-bright-theme
;;                    twilight-theme
                      undo-tree
                      wgrep
                      writegood-mode
                      ))

  (dolist (p my-packages)
    (when (not (package-installed-p p))
      (package-install p))))

; -----------------------------------------[ Load User and Host configurations ]
(progn
  ;; Note: Unless your username is also "lauyuen" you won't be able to use my
  ;; configurations unless you rename the folder ~/.emacs.d/lauyuen to
  ;; ~/.emacs.d/$USER, where $USER is your username.
  (setq custom-file (concat user-emacs-directory user-login-name "/setup.el")
        starter-system-config (concat user-emacs-directory system-name ".el")
        starter-user-config (concat user-emacs-directory user-login-name ".el")
        starter-user-dir (concat user-emacs-directory user-login-name))
  (defun starter-eval-after-init (form)
    (let ((func (list 'lambda nil form)))
      (add-hook 'after-init-hook func)
      (when after-init-time
        (eval form))))
  (starter-eval-after-init
   '(progn
      (when (file-exists-p starter-system-config) (load starter-system-config))
      (when (file-exists-p starter-user-config) (load starter-user-config))
      (when (file-exists-p starter-user-dir)
        (mapc 'load (directory-files starter-user-dir t "^[^#].*el$"))))))

(defun yl-add-path (p)
  (add-to-list 'load-path (concat user-emacs-directory p)))

;; Emacs server
(require 'server)
(when (and (functionp 'server-running-p) (not (server-running-p)))
  (server-start))

(setf backup-directory-alist
      `((".*" . ,temporary-file-directory))
      auto-save-file-name-transforms
      `((".*" ,temporary-file-directory t)))
(put 'dired-find-alternate-file 'disabled nil)
