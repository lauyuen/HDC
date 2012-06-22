##------------------------------------------------------------{}
## File:    ~/.zshrc
## Author:  Will Lau
## Version: 1
## OS:      Arch, Mint Debian, CentOS, Snow Leopard, Windows 7
## LMD:     Sat Oct 30 19:50:34 2010
## Contact: billlau.ca@gmail.com
##------------------------------------------------------------{}

##---------------------------------------------------[ Exports ]
HISTFILE=~/.histfile; HISTSIZE=2048; SAVEHIST=2048
CDPATH='(.. ~);'
MANPATH=/opt/local/share/man:$MANPATH
BROWSER='chromium'; EDITOR='emacsclient'; PAGER='less'
if [ "$TERM" = rxvt-unicode-256color ]; then
  TERM=rxvt-256color
fi

##-----------------------------------------------[ Set Options ]
setopt auto_cd auto_pushd pushd_ignore_dups pushd_silent
setopt complete_in_word correctall interactive_comments
setopt emacs extended_glob auto_remove_slash
setopt hist_expire_dups_first hist_ignore_space
setopt extended_history share_history
setopt list_ambiguous list_types
setopt nobgnice
unsetopt nomatch


##---------------------------------------------------[ Aliases ]
if (( $+commands[emacs-snapshot] )) ; then
   alias emacs="emacs-snapshot"
fi
alias ec="emacsclient"
alias mv="mv -i "
alias rm="rm -i "
if (( $+commands[ls++] )) ; then
    alias ls="ls++ --potsf"
else
    alias ls="ls --color"
fi
alias javad="javadoc -tag param \
      	     -tag pre.:a:\"Precondition: \" -tag return -d ./doc\
	     -link http://java.sun.com/javase/6/docs/api/"
alias umntall="sudo umount ~/mount/*"
alias skldir="~/Dropbox/will/School/current/"
alias sshcse="ssh -Y red.cse.yorku.ca -l cse03307 exo-open --launch TerminalEmulator"
alias matrix="/cs/local/pkg/xfce-4.8.0/bin/Terminal -x matrix -c 5 -l 50 -t \"Will is in the matrix  \" -s 1"
alias top20="du -ah | sort -rh | head -20"
alias less="/usr/share/vim/vim72/macros/less.sh"
##------------------------------------------------[ Completion ]

##---------------------------------------------------[ Exports ]
##--------------------------------------------------[ Programs ]
calc(){ awk "BEGIN { print $* }" ;}
##-------------------------------------------[ Unique OS Files ]

