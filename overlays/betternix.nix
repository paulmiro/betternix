let
  flakePkgs =
    pkgs:
    (builtins.listToAttrs (
      map (name: {
        inherit name;
        value = pkgs.callPackage (../pkgs + "/${name}") { };
      }) (builtins.attrNames (builtins.readDir ../pkgs))
    ));
in
final: prev: {
  betternix = flakePkgs prev;
}
