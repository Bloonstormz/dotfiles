BIN="tree-sitter"
DEPS=("nvim" "cargo")

do_install() {
	cargo install --locked tree-sitter-cli
}

do_clean() {
	cargo uninstall tree-sitter-cli
}
