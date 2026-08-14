{ pkgs, ... }:

{
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  programs.zsh.enable = true;

  users.users.minng01 = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    shell = pkgs.zsh;
  };

  environment.systemPackages = import ../packages/common.nix { inherit pkgs; };

  # Keep this at the release used for the initial NixOS installation.
  system.stateVersion = "26.05";
}
