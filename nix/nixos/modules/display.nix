{
  pkgs,
  config,
  inputs,
  ...
}:

let
  waybar_auto_hide = pkgs.rustPlatform.buildRustPackage {
    pname = "waybar_auto_hide";
    version = "v1.1.1";

    src = pkgs.fetchFromGitHub {
      owner = "Zephirus2";
      repo = "waybar_auto_hide";
      rev = "v1.1.1";
      hash = "sha256-Px8ehO2BMlYZqC0kBBqSE5X00bxu3LoSfxseJ4uTeSI=";
    };

    cargoHash = "sha256-h4RTY04vUzcSf9LjCqlunGRpBhNeQADKSzpBOGP1dSQ=";
  };
in
{
  programs = {
    hyprland = {
      enable = true;
      xwayland.enable = true;
      withUWSM = true;
    };
    uwsm.enable = true;
    hyprlock.enable = true;
  };

  hardware.bluetooth.enable = true;

  services = {
    hypridle.enable = true;
    tuned.enable = true;
    upower.enable = true;
  };

  environment.systemPackages = with pkgs; [
    hyprpaper
    hyprsunset
    swaynotificationcenter
    waybar
    waybar_auto_hide
    wofi
    hyprcursor
    inputs.rose-pine-hyprcursor.packages.${pkgs.stdenv.hostPlatform.system}.default
    inputs.snappy-switcher.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];

  fonts.packages = with pkgs; [
    jetbrains-mono
    nerd-fonts.jetbrains-mono
  ];

  services.displayManager.ly.enable = true;

  hjem = {
    users = config.forMyUser {
      xdg.config.files = {
        hypr.source = ../../../dotfiles/hypr;
        waybar.source = ../../../dotfiles/waybar;
        wofi.source = ../../../dotfiles/wofi;
      };
    };
  };
}
