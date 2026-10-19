{ pkgs, config, ... }:

{
  programs.firefox.enable = true;

  environment.systemPackages = [
    pkgs.ghostty
  ];

  hjem = {
    users = config.forMyUser {
      xdg.config.files = {
        ghostty.source = ../../../dotfiles/ghostty;
      };
    };
  };
}
