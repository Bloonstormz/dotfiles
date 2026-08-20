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
      mkProfile =
        system:
        name:
        package_paths:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        pkgs.buildEnv {
          inherit name;
          paths = builtins.concatMap
            (path: pkgs.lib.toList (pkgs.callPackage path { }))
            package_paths;
          extraOutputsToInstall = [ "man" ];
        };
    in
    {
      packages = forAllSystems (system: {
        dev = mkProfile system "dev" [ ./nix/packages/devTools.nix ./nix/packages/lang.nix ];
        all = mkProfile system "all" [ ./nix/packages/devTools.nix ./nix/packages/lang.nix ./nix/packages/gui.nix ];
        default = self.packages.${system}.dev;
      });

      nixosConfigurations.desktop = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [ ./nix/nixos/hosts/desktop.nix ];
      };
    };
}
