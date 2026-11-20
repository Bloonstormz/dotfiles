{
  pkgs,
  lib,
  config,
  ...
}:

let
  cfg = config.misc.lolcat;
in
{
  options = {
    misc.lolcat = lib.mkEnableOption "Enable lolcat-c";
  };

  config = lib.mkIf cfg {
    environment.systemPackages = [
      (import ../../../packages/lolcat-c.nix { inherit pkgs; })
    ];
  };
}
