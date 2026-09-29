[
    "bash-completion"
    { bat.enable = true; }
    "clippy"
    "curl"
    "delta"
    "fd"
    "fzf"
    { git.enable = true; }
    { lazygit.enable = true; }
    { neovim = {
        enable = true;
        defaultEditor = true;
      };
    }
    { pay-respects.enable = true; }
    "ripgrep"
    "ruff"
    "shellcheck"
    "tree-sitter"
    { tmux.enable = true; }
    "unzip"
    { yazi.enable = true; }
    "oh-my-zsh"
    {
      zsh = {
        enable = true;
        ohMyZsh.enable = true;
      };
    }
    "zsh-powerlevel10k"
  ]
