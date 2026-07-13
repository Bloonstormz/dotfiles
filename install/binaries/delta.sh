BIN="delta"
DEPS=("cargo")

do_install() {
	cargo install git-delta
	link "$DOTFILE_DIR/configs/delta.config" "$HOME/.config/git"

	echo "Downloading Catppuccin Themes for Delta"
	wget -O "$DOTFILE_DIR/configs/catppuccin.gitconfig" https://raw.githubusercontent.com/catppuccin/delta/refs/heads/main/catppuccin.gitconfig

	link "$DOTFILE_DIR/configs/catppuccin.gitconfig" "$HOME/.config/git"
}

do_clean() {
	rm "$HOME/.config/git/catppuccin.gitconfig"
	rm "$DOTFILE_DIR/configs/catppuccin.gitconfig"
	rm "$HOME/.config/git/delta.config"
	cargo uninstall git-delta
}

do_complete() {
	echo "delta --generate-completion %q"
}
