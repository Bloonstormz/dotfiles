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

  hjem = {
    users = config.forEachUser {
      xdg.config.files = {
        nvim.source = ../../../dotfiles/nvim;
      };
    };
  };
}
