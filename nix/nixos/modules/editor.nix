{ pkgs, config, ... }:

{
  programs = {
    neovim = {
      enable = true;
      defaultEditor = true;
    };
  };

  environment.systemPackages = [
    pkgs.ruff
    pkgs.shellcheck
    pkgs.tree-sitter
  ];
}
