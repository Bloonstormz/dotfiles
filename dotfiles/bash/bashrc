#!/bin/bash
# shellcheck disable=SC1091

# If not running interactively, don't do anything
case $- in
*i*) ;;
*) return 1 ;;
esac

if [[ -e "$HOME/.config/.sh_profile" ]]; then
    source "$HOME/.config/.sh_profile" || return
fi

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
    if [ -f "$HOME/.nix-profile/share/bash-completion/bash_completion" ]; then
        . "$HOME/.nix-profile/share/bash-completion/bash_completion"
    elif [ -f /run/current-system/sw/share/bash-completion/bash_completion ]; then
        . /run/current-system/sw/share/bash-completion/bash_completion
    elif [ -f /usr/share/bash-completion/bash_completion ]; then
        . /usr/share/bash-completion/bash_completion
    elif [ -f /etc/bash_completion ]; then
        . /etc/bash_completion
    fi
fi

if [[ -d "$HOME/.config/bash_comp" ]]; then
    mapfile -t BASH_COMPS < <(ls "$HOME/.config/bash_comp")
    for file in "${BASH_COMPS[@]}"; do
        source "$HOME/.config/bash_comp/$file"
    done
    unset BASH_COMPS >/dev/null
fi

if [[ -z $GREEN ]]; then
    GREEN='\[\033[1;32m\]'
fi
if [[ -z $BLUE ]]; then
    BLUE='\[\033[0;34m\]'
fi
if [[ -z $NORMAL ]]; then
    NORMAL='\[\033[0m\]'
fi
if [[ -z $RED ]]; then
    RED='\[\033[31m\]'
fi
PS1="${GREEN}\u${NORMAL}:${BLUE}\w${NORMAL} > \[\033[6 q\]"
unset GREEN BLUE NORMAL RED

complete -c source

true
