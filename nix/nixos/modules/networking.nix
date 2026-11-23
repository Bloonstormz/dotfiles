{ config, ... }:

{
  programs.nm-applet.enable = true;

  networking.networkmanager.enable = true;

  services = {
    openssh.enable = true;
    tailscale.enable = true;
    blueman.enable = true;
  };
}
