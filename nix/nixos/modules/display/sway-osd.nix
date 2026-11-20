{
  pkgs,
  lib,
  config,
  ...
}:

let
  cfg = config.display.sway-osd;
in
{
  options = {
    display.sway-osd = lib.mkEnableOption "Enable Sway OSD";
  };

  config = lib.mkIf cfg {
    environment.systemPackages = with pkgs; [
      swayosd
    ];
  };
}
