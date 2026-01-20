{
  config,
  flake-self,
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
      overlays = [ flake-self.overlays.betternix-overlay ];
    };
  };
}
