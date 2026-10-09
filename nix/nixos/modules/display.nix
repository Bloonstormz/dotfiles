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
  };

  hardware.bluetooth.enable = true;

  services = {
    hypridle.enable = true;
    tuned.enable = true;
    upower.enable = true;
  };

  environment.systemPackages = [
    pkgs.hyprland
    pkgs.noctalia
  ];

  services.displayManager.ly.enable = true;

  hjem = {
    users = config.forEachUser {
      xdg.config.files = {
        hypr.source = ../../../dotfiles/hypr;
        noctalia.source = ../../../dotfiles/noctalia;
      };
    };
  };
}
