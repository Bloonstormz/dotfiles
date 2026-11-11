# shellcheck disable=SC2034
condition="command -v zsh"

run_link() {
	link "$1/zshrc" "$HOME/.zshrc"
	link "$1/p10k.zsh" "$HOME/.p10k.zsh"
}
