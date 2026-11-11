# shellcheck disable=SC2034
condition="command -v bash"

run_link() {
	link "$1/bash_profile" "$HOME/.bash_profile"
	link "$1/bashrc" "$HOME/.bashrc"
}
