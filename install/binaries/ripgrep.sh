BIN="rg"
NAME="ripgrep"
DEPS=("cargo")

do_install() {
	git clone --branch 15.1.0 -- https://github.com/BurntSushi/ripgrep ripgrep_source
	trap "rm -rf ripgrep_source" EXIT
	(
		cd ripgrep_source
		cargo build --release --features 'pcre2'
	)

	mv ./ripgrep_source/target/release/rg .
	ln -sf "$(realpath ./rg)" "$HOME/bin/rg"
}

do_clean() {
	maybe_rm "$HOME/bin/rg"
	maybe_rm rg
}

do_complete() {
	echo "rg --generate complete-%q"
}
