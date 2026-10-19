{ pkgs, config, ... }:

{
  programs = {
    bat.enable = true;
    git.enable = true;
  };

  environment.systemPackages = [
    # TODO: evaluate whether these are needed
    pkgs.clippy
    pkgs.curl
    pkgs.unzip

    pkgs.delta
    pkgs.fd
    pkgs.fzf
    pkgs.lazygit
    pkgs.ripgrep
    pkgs.tmux
    pkgs.unzip
    pkgs.yazi
  ];

  hjem = {
    users = config.forMyUser {
      files = {
        ".gitconfig".source = ../../../dotfiles/git/gitconfig;
        ".tmux.conf".source = ../../../dotfiles/tmux/tmux.conf;
      };

      xdg.config.files = {
        bat.source = ../../../dotfiles/bat;
        git.source = ../../../dotfiles/git/git;
        lazygit.source = ../../../dotfiles/lazygit;
        tmux.source = ../../../dotfiles/tmux/tmux;
        yazi.source = ../../../dotfiles/yazi;
      };
    };
  };
}
