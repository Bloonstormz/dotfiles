{ pkgs }:

let
  ghosttyWrapper = pkgs.writeShellScriptBin "ghostty" ''
    exec ${pkgs.lib.getExe' pkgs.nixgl.auto.nixGLDefault "nixGL"} ${pkgs.lib.getExe pkgs.ghostty} "$@"
  '';
in
pkgs.symlinkJoin {
  name = "ghostty-nixgl";
  paths = [ ghosttyWrapper ];
  postBuild = ''
    mkdir -p $out/share/applications
    ln -s ${pkgs.ghostty}/share/applications/com.mitchellh.ghostty.desktop \
      $out/share/applications/com.mitchellh.ghostty.desktop
    ln -s ${pkgs.ghostty}/share/icons $out/share/icons
  '';
}
