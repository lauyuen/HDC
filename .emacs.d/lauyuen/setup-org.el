(message "loading org-mode customizations ...")
(require 'org-latex)
(require 'writegood-mode)
;;
;; Org-mode Settings
;;
(progn
  (setq org-log-done t
        org-startup-folded 'content
        org-startup-indented t
        org-export-html-validation-link nil
        org-export-htmlize-output-type 'css
        org-directory "~/org/"
        org-mobile-directory "~/Dropbox/orgm/"
        org-mobile-files '(org-agenda-files)
        org-index-for-pull "~/org/inbox.org")
  (add-hook 'org-mode-hook 'visual-line-mode 'append)
  (add-hook 'org-mode-hook 'flyspell-mode 'append)
  (add-hook 'org-mode-hook 'writegood-mode 'append)
  (add-hook 'after-init-hook 'org-mobile-pull)
  (global-set-key "\C-ca" 'org-agenda)
  (global-set-key "\C-cb" 'org-iswitchb))

(add-hook 'message-mode-hook 'turn-on-flyspell 'append)

;; Adgenda files
(setq org-agenda-files (list "~/org/work.org"
                             "~/org/school.org"
                             "~/org/life.org"
                             "~/org/gtd.org"))
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



;; Capture setup
(setq org-default-notes-file (concat org-directory "/notes.org"))
(define-key global-map "\C-cc" 'org-capture)

(setq org-capture-templates
      '(("t" "Todo" entry (file+headline "~/org/gtd.org" "Tasks")
         "* TODO %?\n  %i\n  %a")
        ("j" "Journal" entry (file+datetree "~/org/journal.org")
         "* %?\nEntered on %U\n  %i\n  %a")))

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
