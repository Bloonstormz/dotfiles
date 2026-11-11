# shellcheck disable=SC2034
condition="command -v sh || command -v bash || command -v zsh"

run_link() {
	link "$1/sh_aliases" "$CONFIG/.sh_aliases"
	link "$1/sh_profile" "$CONFIG/.sh_profile"
	link "$1/local_aliases" "$CONFIG/.local_aliases"
}
