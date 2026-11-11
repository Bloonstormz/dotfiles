# shellcheck disable=SC2034
condition="command -v tmux"

run_link() {
	link "$1/tmux.conf" "$HOME/.tmux.conf"
	link "$1/tmux" "$CONFIG/tmux"
}
