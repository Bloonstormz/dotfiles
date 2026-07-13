BIN="zsh"

do_install() {
	wget -O zsh.tar.xz https://www.zsh.org/pub/zsh-5.9.1.tar.xz
	trap "rm zsh.tar.xz" EXIT

	mkdir -p ./zsh
	tar -xf zsh.tar.xz -C ./zsh --strip-components=1
	pushd "./zsh" >/dev/null

	./configure --prefix="$HOME"
	make
	make install

	popd >/dev/null

	# Install oh-my-zsh
	curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh | sh -s -- --keep-zshrc --unattended
	# Install powerlevel10k
	git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"

	if prompt "Make zsh the default shell"; then
		ZSH="$(command -v zsh)"
		if ! [[ -e /etc/shells ]]; then
			echo "/etc/shells does not exit. Aborting.."
			exit 1
		fi
		if ! grep -q "$ZSH" /etc/shells; then
			echo "zsh not in /etc/shells. Updating"
			if ! sudo_access; then
				echo "Sudo Access required. Aborting..."
				exit 1
			fi
			echo "$ZSH" | sudo tee -a /etc/shells
		fi
		chsh -s "$ZSH"
	fi
}

do_clean() {
	echo "I don't know how to uninstall zsh fully"
	# Need to figure out how to clean oh-my-zsh and update login shell if that was changed
	return 1
}
