{
  pkgs,
  lib,
  config,
  ...
}:

let
  cfg = config.display.wallpapers.hyprpaper;
in
{
  options = {
    display.wallpapers.hyprpaper = lib.mkEnableOption "Enable hyprpaper";
  };

  config = lib.mkIf cfg {
    environment.systemPackages = with pkgs; [
      hyprpaper
    ];
  };
}
