{
  pkgs,
  lib,
  config,
  ...
}:

let
  cfg = config.launchers.rofi;
in
{
  options = {
    launchers.rofi = lib.mkEnableOption "Enable Rofi";
  };

  config = lib.mkIf cfg {
    environment.systemPackages = with pkgs; [
      rofi
    ];
  };
}
