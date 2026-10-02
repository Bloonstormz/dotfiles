{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    clang
    gcc

    python314
    python314Packages.dbus-python

    cargo

    nodejs_24
  ];
}
