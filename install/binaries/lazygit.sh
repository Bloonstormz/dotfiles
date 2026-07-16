BIN="lazygit"

do_install() {
	wget -O lazygit.tar.gz https://github.com/jesseduffield/lazygit/releases/download/v0.62.2/lazygit_0.62.2_linux_x86_64.tar.gz
	trap "rm lazygit.tar.gz" EXIT

	extract_tar lazygit.tar.gz -o ./lazygit
	ln -sf "$(realpath ./lazygit/lazygit)" "$HOME/bin/lazygit"
}

do_clean() {
	maybe_rm "$HOME/bin/lazygit"
	maybe_rm -r lazygit
}
