;;; Compiled snippets and support files for `tuareg-mode'
;;; Snippet definitions:
;;;
(yas/define-snippets 'tuareg-mode
                     '(("as" "assert $0;;" "assert" nil nil nil nil nil nil)
                       ("d" "(* $0 *)" "docstring" nil nil nil nil nil nil)
                       ("for" "for ${1:cond} do\n    $0\ndone" "for" nil nil nil nil nil nil)
                       ("fun" "fun ${1:args} -> $0" "fun" nil nil nil nil nil nil)
                       ("|" "| ${1:match} -> $0" "guard" nil nil nil nil nil nil)
                       ("if" "if ${1:cond} then\n   $0\n" "ifthen" nil nil nil nil nil nil)
                       ("if" "if ${1:cond} then\n   $2\nelse\n        $0" "ifthenelse" nil nil nil nil nil nil)
                       ("let" "let ${1:var} $0" "let" nil nil nil nil nil nil)
                       ("l" "[? $1 | $0 ?]" "list_comprehension" nil nil nil nil nil nil)
                       ("m" "let main =\n    $0" "main" nil nil nil nil nil nil)
                       ("match" "match ${1:to_match} with\n      | ${2:matching} -> $0" "match" nil nil nil nil nil nil)
                       ("mod" "module ${1:A} =\n       struct\n       ${2:type t = { name : string; phone : string }}\n       $0\nend;;\n" "module" nil nil nil nil nil nil)
                       ("op" "open ${1:Module}" "open" nil nil nil nil nil nil)
                       ("pr" "Printf.printf \"${1:string}\" ${2:vals};;" "printf" nil nil nil nil nil nil)
                       ("rec" "let rec ${1:fun} ${2:args} =\n    $0" "rec" nil nil nil nil nil nil)
                       ("try" "try\n        $0\nwith\n        $1" "try" nil nil nil nil nil nil)
                       ("type" "type ${1:name} = {${2:var}: ${3:int}$0}" "type_record" nil nil nil nil nil nil)
                       ("type" "type ${1:expr} =\n     | $0" "type_type" nil nil nil nil nil nil)
                       ("val" "val ${1:fun} : $0" "val" nil nil nil nil nil nil)
                       ("wh" "while ${1:cond} do\n      $0\ndone" "while" nil nil nil nil nil nil)))


;;; Do not edit! File generated at Tue Jul 24 11:38:51 2012
