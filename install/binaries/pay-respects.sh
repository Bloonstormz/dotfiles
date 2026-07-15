BIN="pay-respects"
DEPS=("cargo")

do_install() {
	cargo install pay-respects
}

do_clean() {
	cargo uninstall pay-respects
}

do_complete() {
	echo "pay-respects %q"
}
