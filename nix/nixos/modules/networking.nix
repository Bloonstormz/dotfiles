{ config, ... }:

{
  networking.networkmanager.enable = true;

  services = {
    openssh.enable = true;
    tailscale.enable = true;
  };

  hjem = {
    users = config.forMyUser {
      xdg.config.files = {
        nmtui.source = ../../../dotfiles/nmtui;
      };
    };
  };
}
