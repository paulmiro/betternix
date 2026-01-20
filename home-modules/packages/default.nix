{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.betternix.packages;
in
{
  options.betternix.packages = {
    enable = lib.mkEnableOption "enable betternix packages";
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      betternix.pp
    ];
  };
}
