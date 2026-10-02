{
  pkgs,
  config,
  ...
}:

{
  programs = {
    hyprland = {
      enable = true;
      xwayland.enable = true;
      withUWSM = true;
    };
    uwsm.enable = true;
    hyprlock.enable = true;
    dms-shell.enable = true;
  };

  services.hypridle.enable = true;

  environment.systemPackages = [
    pkgs.hyprland
    pkgs.hyprlauncher
    pkgs.swaynotificationcenter
  ];

  services.displayManager.ly.enable = true;

  hjem = {
    users = config.forEachUser {
      xdg.config.files = {
        hypr.source = ../../../dotfiles/hypr;
      };
    };
  };
}
