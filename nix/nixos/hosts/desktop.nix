{ pkgs, ... }:

{
  imports = [ ../configuration.nix ];

  networking.hostName = "desktop";

  environment.systemPackages = import ../../packages/gui.nix { inherit pkgs; };

  # Evaluation placeholders only. Replace these with the generated hardware
  # configuration and a real boot loader before building or deploying the host.
  fileSystems."/" = {
    device = "/dev/disk/by-label/REPLACE_ME";
    fsType = "ext4";
  };
  boot.loader.grub.enable = false;

  # Also add authentication, networking, and a graphical environment before
  # treating this scaffold as a deployable machine configuration.
}
