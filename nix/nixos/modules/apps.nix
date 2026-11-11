{ pkgs, config, ... }:

{
  programs.firefox.enable = true;

  environment.systemPackages = [
    pkgs.ghostty
  ];
}
