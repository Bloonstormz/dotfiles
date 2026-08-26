#!/bin/sh

# Copied from dotfiles/shell/.config/.sh_profile - Try to align these files

if grep -q ^PATH= /etc/environment; then
	. /etc/environment
else
	PATH="$HOME/scripts:$HOME/.local/bin:$HOME/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin"
fi
export PATH
_add_path() {
	if [ $# -gt 1 ]; then
		target="$2"
	else
		target="PATH"
	fi
	if ! eval "[[ '$target' =~ $1 ]]"; then
		eval "$target=$1:\$$target"
	fi
}
_add_path "$HOME/.local/bin"
_add_path "$HOME/bin"
_add_path "$HOME/.local/state/nix/profiles/profile/bin"
