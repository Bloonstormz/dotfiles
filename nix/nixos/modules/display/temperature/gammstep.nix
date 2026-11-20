{
  pkgs,
  lib,
  config,
  ...
}:

let
  cfg = config.display.temperature.gammastep;
in
{
  options = {
    display.temperature.gammastep = lib.mkEnableOption "Enable gammastep";
  };

  config = lib.mkIf cfg {
    environment.systemPackages = with pkgs; [
      gammastep
    ];
  };
}
