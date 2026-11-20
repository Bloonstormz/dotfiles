{
  config,
  lib,
  modulesPath,
  ...
}:

{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  display = {
    sway-nc = true;
    sway-osd = true;
    waybar.enable = true;
    temperature.gammastep = true;
    wallpapers.awww = true;
    wm.niri = true;
  };
  launchers.rofi = true;
  services.displayManager.ly.enable = true;

  hardware.bluetooth.enable = true;

  networking.hostName = "thinkpad";
  boot = {

    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;

    # Do not modify below contents. This was auto-generated during nixOS setup
    initrd.availableKernelModules = [
      "nvme"
      "ehci_pci"
      "xhci_pci_renesas"
      "xhci_pci"
      "usb_storage"
      "sd_mod"
      "rtsx_pci_sdmmc"
    ];
    initrd.kernelModules = [ ];
    kernelModules = [ "kvm-amd" ];
    extraModulePackages = [ ];
  };

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/b73db9af-91fa-4d49-a7e5-c036950c99ec";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/0352-BD0E";
    fsType = "vfat";
    options = [
      "fmask=0022"
      "dmask=0022"
    ];
  };

  swapDevices = [
    { device = "/dev/disk/by-uuid/ceec4a62-6b45-4ebe-bbbf-72043f14b4fb"; }
  ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
