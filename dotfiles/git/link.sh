# shellcheck disable=SC2034
condition="command -v git"

run_link() {
	link "$1/gitconfig" "$HOME/.gitconfig"
	link "$1/git" "$CONFIG/git"
}
