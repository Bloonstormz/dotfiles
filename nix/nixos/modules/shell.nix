{ pkgs, config, ... }:

{
  programs.zsh = {
    enable = true;
  };

  environment = {
    systemPackages = with pkgs; [
      zsh-powerlevel10k
      oh-my-zsh
      pay-respects
    ];

    variables = {
      ZSH = "${pkgs.oh-my-zsh}/share/oh-my-zsh";
    };
  };

  hjem = {
    users = config.forEachUser {
      files = {
        ".bash_profile".source = ../../../dotfiles/bash/bash_profile;
        ".bashrc".source = ../../../dotfiles/bash/bashrc;

        ".p10k.zsh".source = ../../../dotfiles/zsh/p10k.zsh;
        ".zshrc".source = ../../../dotfiles/zsh/zshrc;
      };

      xdg.config.files = {
        ".sh_aliases".source = ../../../dotfiles/shell/sh_aliases;
        ".sh_profile".source = ../../../dotfiles/shell/sh_profile;
      };
    };
  };
}
