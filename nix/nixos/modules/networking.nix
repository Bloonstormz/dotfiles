{ ... }:

{
  networking.networkmanager.enable = true;

  services = {
    openssh.enable = true;
    tailscale.enable = true;
  };
}
