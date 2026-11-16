{ pkgs }:

pkgs.rustPlatform.buildRustPackage {
  pname = "waybar_auto_hide";
  version = "v1.1.1";

  src = pkgs.fetchFromGitHub {
    owner = "Zephirus2";
    repo = "waybar_auto_hide";
    rev = "v1.1.1";
    hash = "sha256-Px8ehO2BMlYZqC0kBBqSE5X00bxu3LoSfxseJ4uTeSI=";
  };

  cargoHash = "sha256-h4RTY04vUzcSf9LjCqlunGRpBhNeQADKSzpBOGP1dSQ=";
}
