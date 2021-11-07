#!/usr/bin/env bash

# If not running interactively, don't do anything
case $- in
  *i*) ;;
  *) return;;
esac

# rc/env dir
export DOTFILES=${HOME}/df
export DOTSH=${DOTFILES}/etc/shell

# .bashenv
[[ -f "${DOTSH}/.bashenv" ]] && . "${DOTSH}/.bashenv"

# config
[[ -f "${DOTSH}/config.bash" ]] && . "${DOTSH}/config.bash"

# disable starting message
if [ ! -f "${HOME}/.sudo_as_admin_successful" ];then
  :> "${HOME}/.sudo_as_admin_successful"
fi

# history
HISTCONTROL=ignoreboth
shopt -s histappend
HISTSIZE=1000
HISTFILESIZE=2000

# other
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"
shopt -s checkwinsize
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
  debian_chroot=$(cat /etc/debian_chroot)
fi

### prompt
case "$TERM" in
  xterm-color|*-256color) color_prompt=yes;;
esac
if [ -n "$force_color_prompt" ]; then
  if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
    color_prompt=yes
  else
    color_prompt=
  fi
fi
function __prompt_git_branch() {
  git symbolic-ref HEAD &>/dev/null &&
    echo "$(git symbolic-ref HEAD 2>/dev/null | sed 's/^refs\/heads\///')"
}
function __prompt_git_branch_brackets() {
  local ps1str=$(__prompt_git_branch)
  [[ ! -z "$ps1str" ]] && echo "[${ps1str}]"
}
PS1='${debian_chroot:+($debian_chroot)}'
if [ "$color_prompt" = yes ]; then
  if [ "$__prompt_style" = 'normal' ];then
    PS1=${PS1}'[\[\033[32m\]\u\[\033[00m\]@\[\033[32m\]\h\[\033[00m\]:\[\033[34m\]\w\[\033[00m\]]\[\033[36m\]'
    PS1=${PS1}'$(__prompt_git_branch_brackets)'
    PS1=${PS1}'[\D{%F(%a)%T}]\[\033[00m\]\n \$ '
  elif [ "$__prompt_style" = 'simple' ];then
    PS1=${PS1}'\[\033[33m\]\w\[\033[00m\]'
    PS1=${PS1}' \[\033[32m\]$(__prompt_git_branch)\[\033[00m\]'
    PS1=${PS1}'\[\033[33m\]\n> \[\033[00m\]'
  fi
else
  if [ "$__prompt_style" = 'normal' ];then
    PS1=${PS1}'[\u@\h:\w]'
    PS1=${PS1}'$(__prompt_git_branch_brackets)'
    PS1=${PS1}'[\D{%F(%a)%T}]\n \$ '
  elif [ "$__prompt_style" = 'simple' ];then
    PS1=${PS1}'\w'
    PS1=${PS1}' $(__prompt_git_branch)'
    PS1=${PS1}'\n> '
  fi
fi
unset color_prompt force_color_prompt
# If this is an xterm set the title to user@host:dir
case "$TERM" in
  xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
  *)
    ;;
esac

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'
    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# colored GCC warnings and errors
#export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# non cd , directory name only -> auto cd
shopt -s autocd
# auto cd -> ls
function auto_cdls() {
  if [ "$OLDPWD" != "$PWD" ]; then
    local fn=$(ls -U1 --color=never | wc -l)
    local -r maxfn=100
    if [[ "$fn" -le "${maxfn}" ]] ; then
      ls --color=auto
    else
      echo "There are over ${maxfn} files."
    fi
    OLDPWD="$PWD"
  fi
}
PROMPT_COMMAND="$PROMPT_COMMAND"$'\n'auto_cdls

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

ulimit -c 0 # not output core files

# rc
[[ -f "${DOTSH}/shrc.bash" ]] && source "${DOTSH}/shrc.bash"

# EOF
