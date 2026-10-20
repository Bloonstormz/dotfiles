{
  description = "NixOS configuration and portable CLI packages";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    hjem = {
      url = "github:feel-co/hjem";
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
      hjem,
      ...
    }@inputs:
    let
      supportedSystems = [
        "x86_64-linux"
        "aarch64-linux"
      ];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
      declarePkg = import ./nix/lib/declarePkg.nix;
      declareHjem = import ./nix/lib/declareHjem.nix;

      devPkgs = [
        (./nix/nixos/modules/shell.nix)
        (./nix/nixos/modules/editor.nix)
        (./nix/nixos/modules/terminalUtil.nix)
      ];
      allPkgs = devPkgs ++ [
        (./nix/nixos/modules/apps.nix)
      ];

      mkProfile =
        system: name: modulePaths:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        pkgs.buildEnv {
          inherit name;
          paths = declarePkg pkgs modulePaths;
          extraOutputsToInstall = [ "man" ];
        };
    in
    {
      packages = forAllSystems (system: {
        dev = mkProfile system "dev" devPkgs;
        all = mkProfile system "all" allPkgs;
        default = self.packages.${system}.dev;
      });

      hjemConfigurations = {
        dev = declareHjem devPkgs;
        all = declareHjem allPkgs;
      };

      nixosConfigurations.thinkpad = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          ./nix/nixos/hosts/thinkpad.nix
          ./nix/nixos/configuration.nix
          ./nix/nixos/modules/virtualisation.nix
          hjem.nixosModules.default
        ]
        ++ allPkgs;
      };
    };
}
