{
  pkgs,
  lib,
  config,
  ...
}:

let
  cfg = config.display.wallpapers.awww;
in
{
  options = {
    display.wallpapers.awww = lib.mkEnableOption "Enable awww";
  };

  config = lib.mkIf cfg {
    environment.systemPackages = with pkgs; [
      awww
    ];
  };
}
