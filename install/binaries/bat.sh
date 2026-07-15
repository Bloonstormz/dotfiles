BIN="bat"

do_install() {
	wget -O bat.tar.gz https://github.com/sharkdp/bat/releases/download/v0.26.1/bat-v0.26.1-x86_64-unknown-linux-gnu.tar.gz
	trap "rm bat.tar.gz" EXIT

	extract_tar "bat.tar.gz" -s -o bat
	ln -sf "$(realpath ./bat/bat)" "$HOME/bin/bat"

	mkdir -p "$(dirname "$(bat --config-file)")"
	link "$DOTFILE_DIR/configs/bat.config" "$(bat --config-file)"
}

do_clean() {
	rm "$(bat --config-file)"
	rm -r ./bat
}

do_complete() {
	echo "bat --completion %q"
}
