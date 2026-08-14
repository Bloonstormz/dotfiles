#!/bin/sh

# If not running interactively, don't do anything
case $- in
*i*) ;;
*) return 1 ;;
esac

if [ "${DOTFILES_PROFILE_LOADED:-}" = 1 ]; then
	return 0
fi
DOTFILES_PROFILE_LOADED=1

if [ -e /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]; then
	. /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
elif [ -e "$HOME/.nix-profile/etc/profile.d/nix.sh" ]; then
	. "$HOME/.nix-profile/etc/profile.d/nix.sh"
fi

[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

export EDITOR="nvim"
export MANPATH="$HOME/share/man${MANPATH:+:$MANPATH}"
export MANPAGER="nvim +Man!"

PATH="$HOME/scripts:$HOME/.local/bin:$PATH"
export PATH

[ -e "$HOME/.config/.localrc" ] && . "$HOME/.config/.localrc"

if [ -e "$HOME/.config/.sh_aliases" ]; then
	. "$HOME/.config/.sh_aliases"
fi

if [ -n "${BASH_VERSION:-}" ] && [ -z "${DOTFILES_BASHRC_LOADED:-}" ] && [ -e "$HOME/.bashrc" ]; then
	. "$HOME/.bashrc"
fi

true
