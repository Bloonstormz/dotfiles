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
}
