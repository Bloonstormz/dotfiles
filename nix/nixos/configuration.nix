{
  config,
  pkgs,
  lib,
  ...
}:

{
  options = {
    forMyUser = lib.mkOption {
    };
  };

  imports = [
    ./modules/display.nix
    ./modules/audio.nix
    ./modules/networking.nix
    ./modules/lang.nix
  ];

  config = {
    forMyUser = setting: {
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

    users.users = config.forMyUser {
      isNormalUser = true;
      extraGroups = [
        "wheel"
        "networkmanager"
      ];
      shell = pkgs.zsh;
    };

    hjem.users = config.forMyUser {
      xdg.config.files = {
        pictures.source = ../../dotfiles/pictures;
      };
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
