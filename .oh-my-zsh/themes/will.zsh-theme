# zsh theme requires 256 color enabled terminal
# i.e TERM=xterm-256color
# Preview - http://www.flickr.com/photos/adelcampo/4556482563/sizes/o/
# based on robbyrussell's shell but louder!

PROMPT='%{$fg_bold[magenta]%}$(git_prompt_info) %F{208}%c%f
%{$fg_bold[white]%}%# %{$reset_color%}'
if [[ "$USERNAME" == *lauyuen* ]] || [ "$USERNAME" = "cse03307" ]
then
  RPROMPT='%B%F{160}l%f%F{196}a%f%F{202}u%f%F{208}y%f%F{214}u%f%F{220}e%f%F{226}n%f'
else
  RPROMPT='%B%F{124}%n%f%'
fi

RPROMPT=$RPROMPT'%{$fg_bold[white]%}@'

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
  RPROMPT=$RPROMPT'%B%F{84}%m%f%'
fi


ZSH_THEME_GIT_PROMPT_PREFIX="%F{154}±|%f%F{124}"
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_DIRTY=" %{$fg[red]%}%Bx%b%F{154}|%f%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_CLEAN=" %{$fg[green]%}<3%F{154}|"
