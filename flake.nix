{
  description = "Bloonstormz's command-line tools, managed with Home Manager";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ nixpkgs, home-manager, ... }:
    let
      system = "x86_64-linux";
      username = builtins.getEnv "USER";
      homeDirectory = builtins.getEnv "HOME";
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      homeConfigurations.default = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [ ./home.nix ];
        extraSpecialArgs = { inherit username homeDirectory; };
      };

      # Lets install.sh use the same pinned Home Manager as this flake.
      packages.${system}.home-manager = home-manager.packages.${system}.home-manager;
    };
}
