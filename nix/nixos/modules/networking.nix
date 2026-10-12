{ config, ... }:

{
  networking.networkmanager.enable = true;

  services = {
    openssh.enable = true;
    tailscale.enable = true;
  };

  hjem = {
    users = config.forEachUser {
      xdg.config.files = {
        nmtui.source = ../../../dotfiles/nmtui;
      };
    };
  };
}
