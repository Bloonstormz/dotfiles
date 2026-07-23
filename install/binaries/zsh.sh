BIN="zsh"

do_install() {
	wget -O zsh.tar.xz https://sourceforge.net/projects/zsh/files/latest/download
	trap "rm zsh.tar.xz" EXIT

	mkdir -p ./zsh
	tar -xf zsh.tar.xz -C ./zsh --strip-components=1
	pushd "./zsh" >/dev/null

	./configure --prefix="$HOME"
	make
	make install

	popd >/dev/null

	if [[ ! -e "$HOME/oh-my-zsh" ]]; then
		# Install oh-my-zsh
		curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh | sh -s -- --keep-zshrc --unattended
	fi
	local p10k_install_path="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
	if [[ ! -e "$p10k_install_path" ]]; then
		# Install powerlevel10k
		git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$p10k_install_path"
	fi

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
