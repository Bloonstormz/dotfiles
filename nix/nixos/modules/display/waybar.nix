{
  pkgs,
  lib,
  config,
  ...
}:

let
  cfg = config.display.waybar;
in
{
  options = {
    display.waybar.enable = lib.mkEnableOption "Enable waybar";
    display.waybar.autohide = lib.mkEnableOption "Hide waybar until cursor hover";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages =
      with pkgs;
      [
        waybar
      ]
      ++ (
        if cfg.autohide then
          [
            (import ../../packages/waybar-auto-hide.nix { inherit pkgs; })
          ]
        else
          [ ]
      );
  };
}
