{ ... }:

{
  imports = [ ../configuration.nix ];

  networking.hostName = "thinkpad";

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
}
