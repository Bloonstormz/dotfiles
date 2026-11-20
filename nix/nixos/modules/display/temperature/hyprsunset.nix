{
  pkgs,
  lib,
  config,
  ...
}:

let
  cfg = config.display.temperature.hyprsunset;
in
{
  options = {
    display.temperature.hyprsunset = lib.mkEnableOption "Enable hyprsunset";
  };

  config = lib.mkIf cfg {
    environment.systemPackages = with pkgs; [
      hyprsunset
    ];
  };
}
