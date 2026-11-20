{
  pkgs,
  lib,
  config,
  ...
}:

let
  cfg = config.display.wm.niri;
in
{
  options = {
    display.wm.niri = lib.mkEnableOption "Enable Niri WM";
  };

  config = lib.mkIf cfg {
    programs.niri.enable = true;

    services.hypridle.enable = true;
    programs.hyprlock.enable = true;

    environment.systemPackages = with pkgs; [
      dex
    ];

    fonts.packages = with pkgs; [
      jetbrains-mono
      nerd-fonts.jetbrains-mono
    ];
  };
}
