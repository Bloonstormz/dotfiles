BIN="nvim"
NAME="neovim"

do_install() {
	wget -O nvim.tar.gz https://github.com/neovim/neovim/releases/download/v0.12.3/nvim-linux-x86_64.tar.gz
	trap "rm nvim.tar.gz" EXIT

	extract_tar nvim.tar.gz -o ./nvim -s
	ln -sf "$(realpath ./nvim/bin/nvim)" "$HOME/bin/nvim"
}

do_clean() {
	rm "$HOME/bin/nvim"
	rm -r nvim
}
