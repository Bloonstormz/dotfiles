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
      mkCommonProfile =
        system:
        let
          pkgs = import nixpkgs { inherit system; };
        in
        pkgs.buildEnv {
          name = "dotfiles-common";
          paths = import ./nix/packages/common.nix { inherit pkgs; };
          extraOutputsToInstall = [ "man" ];
        };
    in
    {
      packages = forAllSystems (system: {
        common = mkCommonProfile system;
        default = self.packages.${system}.common;
      });

      nixosConfigurations.desktop = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [ ./nix/nixos/hosts/desktop.nix ];
      };
    };
}
