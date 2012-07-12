(message "loading org-mode customizations ...")
(require 'org-latex)

;;
;; Org-mode Settings
;;
(progn
  (setq org-log-done t)
  (setq org-startup-folded 'content)
  (setq org-startup-indented t)
  (setq org-export-html-validation-link nil)
  (setq org-export-htmlize-output-type 'css)
  (add-hook 'org-mode-hook 'visual-line-mode 'append)
  (add-hook 'org-mode-hook 'flyspell-mode 'append)
  (global-set-key "\C-ca" 'org-agenda)
  (global-set-key "\C-cb" 'org-iswitchb))

(add-hook 'message-mode-hook 'turn-on-flyspell 'append)

;; Adgenda files
(setq org-agenda-files (list "~/org/work.org"
                             "~/org/school.org"
                             "~/org/life.org"))
(setq org-todo-keywords
      (quote ((sequence "TODO(t)" "NEXT(n)" "STARTED(s)" "|" "DONE(d!/!)")
              (sequence "WAITING(w@/!)" "SOMEDAY(S!)" "|" "CANCELLED(c@/!)" "PHONE")
              (sequence "OPEN(O!)" "|" "CLOSED(C!)"))))

(setq org-todo-keyword-faces
      (quote (("TODO" :foreground "red" :weight bold)
              ("NEXT" :foreground "blue" :weight bold)
              ("STARTED" :foreground "blue" :weight bold)
              ("DONE" :foreground "forest green" :weight bold)
              ("WAITING" :foreground "orange" :weight bold)
              ("SOMEDAY" :foreground "magenta" :weight bold)
              ("CANCELLED" :foreground "forest green" :weight bold)
              ("OPEN" :foreground "blue" :weight bold)
              ("CLOSED" :foreground "forest green" :weight bold)
              ("PHONE" :foreground "forest green" :weight bold))))

;; Org Latex Setting
(add-to-list 'org-export-latex-classes
             '("yarticle"
               "\\documentclass[11pt,letterpaper]{article}
\\usepackage[T1]{fontenc}
%\\usepackage{fontspec}
\\usepackage{graphicx} 
%\\defaultfontfeatures{Mapping=tex-text}
\\usepackage{hyperref}
\\hypersetup{
    colorlinks,%
    citecolor=black,%
    filecolor=black,%
    linkcolor=blue,%
    urlcolor=black
}
%\\setromanfont{Gentium}
%\\setromanfont [BoldFont={Gentium Basic Bold},
%                ItalicFont={Gentium Basic Italic}]{Gentium Basic}
%\\setsansfont{Charis SIL}
%\\setmonofont[Scale=0.8]{DejaVu Sans Mono}
\\usepackage{geometry}
\\geometry{letterpaper, textwidth=6.5in, textheight=10in,
            marginparsep=7pt, marginparwidth=.6in}
\\pagestyle{empty}
\\title{}
%      [NO-DEFAULT-PACKAGES]
%      [NO-PACKAGES]"
               ("\\section{%s}" . "\\section*{%s}")
               ("\\subsection{%s}" . "\\subsection*{%s}")
               ("\\subsubsection{%s}" . "\\subsubsection*{%s}")
               ("\\paragraph{%s}" . "\\paragraph*{%s}")
               ("\\subparagraph{%s}" . "\\subparagraph*{%s}")))
