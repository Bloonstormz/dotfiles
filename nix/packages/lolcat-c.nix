{
  pkgs,
}:

pkgs.stdenv.mkDerivation (finalAttrs: {
  pname = "lolcat-c";
  version = "1.5";

  src = pkgs.fetchFromGitHub {
    owner = "jaseg";
    repo = "lolcat";
    rev = "v1.5";
    hash = "sha256-rEqweE9Pjj6aaPali66F5nOCuIu1INBkykVa+TnxBe8=";
  };

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    install -m755 lolcat $out/bin/lolcat

    runHook postInstall
  '';

  meta = {
    description = "High-performance implementation of https://github.com/busyloop/lolcat";
    homepage = "https://github.com/jaseg/lolcat";
  };
})
