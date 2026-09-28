{ pkgs, ... }:

{
  imports = [ ../configuration.nix ];

  networking.hostName = "desktop";

  environment.systemPackages = import ../../packages/gui.nix { inherit pkgs; };

  boot.loader.grub.enable = false;

  # Also add authentication, networking, and a graphical environment before
  # treating this scaffold as a deployable machine configuration.
}
