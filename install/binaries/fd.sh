BIN="fd"

do_install() {
	wget -O fd.tar.gz https://github.com/sharkdp/fd/releases/download/v10.4.2/fd-v10.4.2-x86_64-unknown-linux-gnu.tar.gz
	trap "rm fd.tar.gz" EXIT

	extract_tar ./fd.tar.gz -o ./fd_out -s
	mv ./fd_out/fd .
	ln -sf "$(realpath ./fd)" "$HOME/bin/fd"
	rm -rf ./fd_out
}

do_clean() {
	maybe_rm fd
	maybe_rm "$HOME/bin/fd"
}

do_complete() {
	echo "fd --gen-completions %q"
}
