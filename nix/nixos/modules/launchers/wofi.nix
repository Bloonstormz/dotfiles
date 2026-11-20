{
  pkgs,
  lib,
  config,
  ...
}:

let
  cfg = config.launchers.wofi;
in
{
  options = {
    launchers.wofi = lib.mkEnableOption "Enable Wofi";
  };

  config = lib.mkIf cfg {
    environment.systemPackages = with pkgs; [
      wofi
    ];
  };
}
