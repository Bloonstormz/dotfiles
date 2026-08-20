#!/bin/zsh
# shellcheck disable=SC1091

# If not running interactively, don't do anything
case $- in
*i*) ;;
*) return 1 ;;
esac

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

for nix_profile in "$HOME/.nix-profile" /run/current-system/sw; do
  [[ -d "$nix_profile/share/zsh/site-functions" ]] && fpath+=("$nix_profile/share/zsh/site-functions")
done

# Add bash compatibility for completions
autoload -U +X compinit && compinit
autoload -U +X bashcompinit && bashcompinit

if [[ -e "$HOME/.config/.sh_profile" ]]; then
  source ~/.config/.sh_profile || return
fi

# Path to your Oh My Zsh installation.
if [[ -d "$HOME/.nix-profile/share/oh-my-zsh" ]]; then
  export ZSH="$HOME/.nix-profile/share/oh-my-zsh"
elif [[ -d /run/current-system/sw/share/oh-my-zsh ]]; then
  export ZSH="/run/current-system/sw/share/oh-my-zsh"
else
  export ZSH="$HOME/.oh-my-zsh"
fi

# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME=""

COMPLETION_WAITING_DOTS="true"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

plugins=(
    web-search
    repo
)

export LESS="-R -F"

[[ -f "$ZSH/oh-my-zsh.sh" ]] && source "$ZSH/oh-my-zsh.sh"

for powerlevel10k_theme in \
  "$HOME/.nix-profile/share/zsh-powerlevel10k/powerlevel10k.zsh-theme" \
  /run/current-system/sw/share/zsh-powerlevel10k/powerlevel10k.zsh-theme \
  "${ZSH_CUSTOM:-$ZSH/custom}/themes/powerlevel10k/powerlevel10k.zsh-theme"; do
  if [[ -f "$powerlevel10k_theme" ]]; then
    source "$powerlevel10k_theme"
    break
  fi
done
unset powerlevel10k_theme nix_profile

# User configuration

_reset_to_beam() {
    printf "\033[6 q"
}
precmd_functions+=(_reset_to_beam)

HISTSIZE=1000
unsetopt sharehistory
setopt appendhistory
setopt extendedhistory

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ -f ~/.p10k.zsh ]] && source ~/.p10k.zsh

true
