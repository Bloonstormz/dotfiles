# Takes a list of nixOS modules and turns it into
# a list of nix pkgs

pkgs: modules:
let
  fromModule =
    module:
    let
      res = import module { inherit pkgs; };
    in
    res.environment.systemPackages ++ (builtins.mapAttrs (name: value: pkgs.${name}) res.programs);
in
builtins.concatMap fromModule modules
