{
  description = "NixOS configuration and portable CLI packages";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    nixgl = {
      url = "github:nix-community/nixGL";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    rose-pine-hyprcursor = {
      url = "github:ndom91/rose-pine-hyprcursor";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    snappy-switcher = {
      url = "github:OpalAayan/snappy-switcher";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      nixgl,
      ...
    }@inputs:
    let
      devPkgs = [
        (./nix/nixos/modules/shell.nix)
        (./nix/nixos/modules/editor.nix)
        (./nix/nixos/modules/terminalUtil.nix)
      ];
      allPkgs = devPkgs ++ [
        (./nix/nixos/modules/apps.nix)
      ];
    in
    {
      nixosConfigurations.thinkpad = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          ./nix/nixos/hosts/thinkpad.nix
          ./nix/nixos/configuration.nix
          ./nix/nixos/modules/virtualisation.nix
        ]
        ++ allPkgs;
      };

      packages = nixpkgs.lib.genAttrs [ "x86_64-linux" "aarch64-linux" ] (system:
        let
          pkgs = import nixpkgs {
            inherit system;
            overlays = [ nixgl.overlay ];
          };
        in
        {
          ghostty = import ./nix/packages/ghostty-wrapper.nix { inherit pkgs; };
          waybar_auto_hide = import ./nix/packages/waybar-auto-hide.nix { inherit pkgs; };
          lolcat-c = import ./nix/packages/lolcat-c.nix { inherit pkgs; };
        });
    };
}
