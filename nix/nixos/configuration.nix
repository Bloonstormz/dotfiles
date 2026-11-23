{
  pkgs,
  ...
}:

{
  imports = [
    ./modules/audio.nix
    ./modules/networking.nix
    ./modules/lang.nix
    ./modules/display/sway-nc.nix
    ./modules/display/sway-osd.nix
    ./modules/display/waybar.nix
    ./modules/display/temperature/gammstep.nix
    ./modules/display/temperature/hyprsunset.nix
    ./modules/display/wallpapers/awww.nix
    ./modules/display/wallpapers/hyprpaper.nix
    ./modules/display/wm/hyprland.nix
    ./modules/display/wm/niri.nix
    ./modules/launchers/rofi.nix
    ./modules/launchers/wofi.nix
    ./modules/misc/lolcat.nix
  ];

  config = {
    nix.settings.experimental-features = [
      "nix-command"
      "flakes"
    ];

    boot.kernelPackages = pkgs.linuxPackages_latest;
    xdg.autostart.enable = true;

    programs = {
      nix-ld.enable = true;
    };

    users.users.minng01 = {
      isNormalUser = true;
      extraGroups = [
        "wheel"
        "networkmanager"
      ];
      shell = pkgs.zsh;
    };

    environment.systemPackages = with pkgs; [
      nerd-fonts.jetbrains-mono
      fastfetch
      nix-search
      nix-index
    ];

    services.power-profiles-daemon.enable = true;

    time.timeZone = "Europe/London";

    # Keep this at the release used for the initial NixOS installation.
    system.stateVersion = "26.05";
  };
}
