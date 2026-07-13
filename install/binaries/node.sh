BIN="node"

do_install() {
	# Taken from node.js.org/en/download

	# Download and install nvm:
	curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.4/install.sh | bash

	# Hide warnings about not being able to evaluate $HOME source
	# shellcheck disable=SC1091
	\. "$HOME/.nvm/nvm.sh" # in lieu of restarting the shell

	# Download and install Node.js:
	nvm install 24
}

do_clean() {
	echo "I don't know how to uninstall node"
	return 1
}
