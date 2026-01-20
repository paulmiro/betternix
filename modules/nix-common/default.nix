{
  config,
  lib,
  ...
}:
let
  cfg = config.betternix.nix-common;
in
{
  options.betternix.nix-common = {
    enable = lib.mkEnableOption "activate nix-common";
  };

  config = lib.mkIf cfg.enable {
    nixpkgs = {
      overlays = map (filename: import ../../overlays + "/${filename}") (
        builtins.attrNames (builtins.readDir ../../overlays)
      );
    };
  };
}
