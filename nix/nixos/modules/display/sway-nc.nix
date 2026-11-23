{
  pkgs,
  lib,
  config,
  ...
}:

let
  cfg = config.display.sway-nc;
in
{
  options = {
    display.sway-nc = lib.mkEnableOption "Enable Sway Notification Center";
  };

  config = lib.mkIf cfg {
    environment.systemPackages = with pkgs; [
      swaynotificationcenter
      nwg-look
    ];
  };
}
