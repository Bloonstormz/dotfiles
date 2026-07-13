BIN="cargo"
NAME="Rust"

do_install() {
	curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- --no-modify-path
	# shellcheck disable=SC1091
	. "$HOME/.cargo/env"
}
do_complete() {
	echo "rustup completions %q"
	echo "_rust"

	echo "rustup completions %q cargo"
	echo "_cargo"
}

do_clean() {
	echo "I don't know how to uninstall rust"
	return 1
}
