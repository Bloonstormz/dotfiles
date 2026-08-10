#!/bin/zsh

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

fpath+=("$HOME/.config/zsh_comp")

# Add bash compatibility for completions
autoload -U +X compinit && compinit
autoload -U +X bashcompinit && bashcompinit

source ~/.config/.profile || return

# Prefer an existing manual installation, otherwise use Home Manager's package.
if [[ -d "$HOME/.oh-my-zsh" ]]; then
  export ZSH="$HOME/.oh-my-zsh"
else
  export ZSH="$HOME/.nix-profile/share/oh-my-zsh"
fi

# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
if [[ -e "$ZSH/custom/themes/powerlevel10k/powerlevel10k.zsh-theme" ]]; then
  ZSH_THEME="powerlevel10k/powerlevel10k"
else
  ZSH_THEME=""
fi

COMPLETION_WAITING_DOTS="true"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

plugins=(
    web-search
    repo
)

export LESS="-R -F"

source $ZSH/oh-my-zsh.sh

if [[ -z "$ZSH_THEME" ]]; then
  source "$HOME/.nix-profile/share/zsh-powerlevel10k/powerlevel10k.zsh-theme"
fi

# User configuration

_reset_to_beam() {
    printf "\033[6 q"
}
precmd_functions+=(_reset_to_beam)

HISTSIZE=1000
unsetopt sharehistory
setopt appendhistory
setopt extendedhistory

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    alias grep='grep --color=auto -n'
    alias rgrep='rgrep --color=auto -n'
    alias fgrep='fgrep --color=auto -n'
    alias egrep='egrep --color=auto -n'
fi

# some more ls aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

true
