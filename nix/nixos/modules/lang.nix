{ pkgs }:

with pkgs;
[
  clang
  cargo
  gcc

  python314
  python314Packages.dbus-python

  nodejs_24
]
