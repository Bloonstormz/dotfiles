{ pkgs, username, homeDirectory, ... }:

{
  assertions = [
    {
      assertion = username != "" && homeDirectory != "";
      message = "USER and HOME must be available; evaluate this flake with --impure";
    }
  ];

  home = {
    inherit username homeDirectory;
    stateVersion = "26.05";

    # Configuration files intentionally stay out of Home Manager. install.sh
    # links the files in this repository directly into $HOME.
    packages = with pkgs; [
      bash-completion
      bat
      cargo
      clippy
      fd
      git
      git-delta
      lazygit
      neovim
      nodejs_24
      oh-my-zsh
      pay-respects
      ripgrep
      ruff
      rustc
      rustfmt
      tmux
      tree-sitter
      zsh
      zsh-powerlevel10k
    ];
  };

  programs.home-manager.enable = true;
}
