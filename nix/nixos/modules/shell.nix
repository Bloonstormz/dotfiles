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
}
