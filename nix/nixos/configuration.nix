{ pkgs, lib, ... }:

let
  declarePkg = import ../lib/declarePkg.nix;
  devTools = import ../packages/devTools.nix;
  gui = import ../packages/gui.nix;
in
{
  imports = [ ./hardware-configuration.nix ];
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  boot.kernelPackages = pkgs.linuxPackages_latest;

  programs =
    lib.mergeAttrsList (declarePkg {
      inherit pkgs;
      pkgList = devTools;
      type = "nixos-programs";
    })
    // lib.mergeAttrsList (declarePkg {
      inherit pkgs;
      pkgList = gui;
      type = "nixos-programs";
    })
    // {
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

  environment.systemPackages =
    (declarePkg {
      inherit pkgs;
      pkgList = devTools;
      type = "pkgs";
    })
    ++ (with pkgs; [
      nerd-fonts.jetbrains-mono
      fastfetch
    ])
    ++ (pkgs.callPackage ./modules/lang.nix { })
    ++ (declarePkg {
      inherit pkgs;
      pkgList = gui;
      type = "pkgs";
    });

  time.timeZone = "Europe/London";

  # Keep this at the release used for the initial NixOS installation.
  system.stateVersion = "26.05";
}
