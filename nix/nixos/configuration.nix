{
  pkgs,
  lib,
  ...
}:

{
  options = {
    forEachUser = lib.mkOption {
    };
  };

  imports = [
    ./modules/display.nix
    ./modules/audio.nix
    ./modules/networking.nix
    ./modules/lang.nix
  ];

  config = {
    forEachUser = setting: {
      minng01 = setting;
    };

    nix.settings.experimental-features = [
      "nix-command"
      "flakes"
    ];

    boot.kernelPackages = pkgs.linuxPackages_latest;

    programs = {
      nix-ld.enable = true;
    };

    users.users.minng01 = {
      isNormalUser = true;
      extraGroups = [
        "wheel"
        "networkmanager"
      ];
      shell = pkgs.zsh;
    };

    environment.systemPackages = with pkgs; [
      nerd-fonts.jetbrains-mono
      fastfetch
    ];

    time.timeZone = "Europe/London";

    # Keep this at the release used for the initial NixOS installation.
    system.stateVersion = "26.05";
  };
}
