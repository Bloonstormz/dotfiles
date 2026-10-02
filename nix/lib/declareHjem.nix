# Takes a list of nixOS modules and turns it into
# an attribute set representing a hjem manifest

let
  fromHjemSet =
    rel: set:
    builtins.mapAttrs (dest: source: {
      type = "symlink";
      inherit source;
      target = "~" + rel + "/" + dest;
    }) set;
in
pkgs: modules:
let
  fromModule =
    module:
    let
      inherit ((import module { inherit pkgs; })) hjem;
    in
    (fromHjemSet "" hjem.files) ++ (fromHjemSet "/.config" hjem.xdg.config.files);
in
{
  version = 3;
  files = builtins.concatMap fromModule modules;
}
