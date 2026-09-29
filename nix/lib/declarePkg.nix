{
  pkgs,
  pkgList,
  type,
}:

if type == "nixos-programs" then
  builtins.filter (x: builtins.typeOf x == "set") pkgList
else if type == "pkgs" then
  let
    pkgNames = builtins.filter (x: builtins.typeOf x == "string") pkgList;
  in
  builtins.map (x: pkgs.${x}) pkgNames
else
  map (
    x:
    if builtins.typeOf x == "string" then
      pkgs.${x}
    else
      let
        pkgName = builtins.elemAt (builtins.attrNames x) 0;
      in
      pkgs.${pkgName}
  ) pkgList
