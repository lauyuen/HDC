; ---------------------------------------------------------[ Mode list setting ]
(autoload 'apache-mode "apache-mode" nil t)
(setq auto-mode-alist
      (append '(("\\.zsh\\'" . sh-mode)
                ("\\.htaccess\\'"   . apache-mode)
                ("httpd\\.conf\\'"  . apache-mode)
                ("srm\\.conf\\'"    . apache-mode)
                ("access\\.conf\\'" . apache-mode)
                ("sites-\\(available\\|enabled\\)/" . apache-mode)
                ("\\.py\\'" . python-mode)
                )
              auto-mode-alist))

; -----------------------------------------------------------[ Scripting modes ]
(add-hook 'after-save-hook              ; Make script executable
  'executable-make-buffer-file-executable-if-script-p)

; ----------------------------------------------------------[ Programming mode ]
