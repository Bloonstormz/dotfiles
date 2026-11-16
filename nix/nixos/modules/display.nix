{ pkgs
, config
, inputs
, ...
}:

{
  programs = {
    hyprland = {
      enable = true;
      xwayland.enable = true;
      withUWSM = true;
    };
    uwsm.enable = true;
    hyprlock.enable = true;
  };

  hardware.bluetooth.enable = true;

  services = {
    hypridle.enable = true;
    tuned.enable = true;
    upower.enable = true;
  };

  environment.systemPackages = with pkgs; [
    hyprpaper
    hyprsunset
    swaynotificationcenter
    waybar
    (import ../../packages/waybar-auto-hide.nix { inherit pkgs; })
    wofi
    hyprcursor
    inputs.rose-pine-hyprcursor.packages.${pkgs.stdenv.hostPlatform.system}.default
    inputs.snappy-switcher.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];

  fonts.packages = with pkgs; [
    jetbrains-mono
    nerd-fonts.jetbrains-mono
  ];

  services.displayManager.ly.enable = true;
}
