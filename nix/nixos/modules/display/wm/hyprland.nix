{
  pkgs,
  lib,
  inputs,
  config,
  ...
}:

let
  cfg = config.display.wm.hyprland;
in
{
  options = {
    display.wm.hyprland = lib.mkEnableOption "Enable hyprland";
  };

  config = lib.mkIf cfg {
    qt.style = "breeze";

    programs = {
      hyprland = {
        enable = true;
        xwayland.enable = true;
        withUWSM = true;
      };
      uwsm.enable = true;
      hyprlock.enable = true;
    };

    services = {
      hypridle.enable = true;
    };

    environment.systemPackages = with pkgs; [
      dex
      hyprcursor
      inputs.rose-pine-hyprcursor.packages.${pkgs.stdenv.hostPlatform.system}.default
      inputs.snappy-switcher.packages.${pkgs.stdenv.hostPlatform.system}.default
    ];

    fonts.packages = with pkgs; [
      jetbrains-mono
      nerd-fonts.jetbrains-mono
    ];
  };
}
