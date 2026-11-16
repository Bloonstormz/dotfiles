{
  description = "NixOS configuration and portable CLI packages";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    rose-pine-hyprcursor = {
      url = "github:ndom91/rose-pine-hyprcursor";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    snappy-switcher = {
      url = "github:OpalAayan/snappy-switcher";
    };
  };

  outputs =
    { self
    , nixpkgs
    , ...
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

      packages = nixpkgs.lib.genAttrs [ "x86_64-linux" "aarch64-linux" ] (system: {
        waybar_auto_hide = import ./nix/packages/waybar-auto-hide.nix {
          pkgs = nixpkgs.legacyPackages.${system};
        };
      });
    };
}
