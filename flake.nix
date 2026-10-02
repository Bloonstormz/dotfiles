{
  description = "NixOS configuration and portable CLI packages";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs =
    { self, nixpkgs }:
    let
      supportedSystems = [
        "x86_64-linux"
        "aarch64-linux"
      ];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
      declarePkg = import ./nix/lib/declarePkg.nix;
      mkProfile =
        system: name: package_paths:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        pkgs.buildEnv {
          inherit name;
          paths = builtins.concatMap (
            path:
            pkgs.callPackage declarePkg {
              inherit pkgs;
              pkgList = path;
              type = "all-pkgs";
            }
          ) package_paths;
          extraOutputsToInstall = [ "man" ];
        };
    in
    {
      packages = forAllSystems (system: {
        dev = mkProfile system "dev" [ ./nix/packages/devTools.nix ];
        all = mkProfile system "all" [
          ./nix/packages/devTools.nix
          ./nix/packages/gui.nix
        ];
        default = self.packages.${system}.dev;
      });

      nixosConfigurations.thinkpad = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./nix/nixos/hosts/thinkpad.nix
          ./nix/nixos/configuration.nix
        ];
      };
    };
}
