# zsh theme requires 256 color enabled terminal
# i.e TERM=xterm-256color
# Preview - http://www.flickr.com/photos/adelcampo/4556482563/sizes/o/
# based on robbyrussell's shell but louder!

PROMPT='%{$fg_bold[magenta]%}$(git_prompt_info) %F{yellow}%c%f
%{$fg_bold[black]%}%# %{$reset_color%}'
if [[ "$USERNAME" == *lauyuen* ]] || [ "$USERNAME" = "cse03307" ]
then
  RPROMPT='%B%F{27}l%f%F{33}a%f%F{39}u%f%F{45}y%f%F{47}u%f%F{48}e%f%F{46}n%f'
else
  RPROMPT='%B%F{124}%n%f%'
fi

RPROMPT=$RPROMPT'%{$fg_bold[black]%}@'

if [[ "$HOST" == *constitution* ]]
then
  RPROMPT=$RPROMPT'%F{198}%m%f%{$reset_color%}'
elif [[ "$HOST" == *codification* ]]
then
  RPROMPT=$RPROMPT'%F{154}%m%f%{$reset_color%}'
elif [[ "$HOST" == *red* ]]
then
  RPROMPT=$RPROMPT'%F{196}%m%f%{$reset_color%}'
else
  RPROMPT=$RPROMPT'%B%F{cyan}%m%f%'
fi


ZSH_THEME_GIT_PROMPT_PREFIX="%F{blue}±<%f%F{red}"
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_DIRTY=" %{$fg[red]%}%Bx%b%F{blue}>%f%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_CLEAN=" %{$fg[green]%}<3%F{blue}>"
