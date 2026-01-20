{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.betternix.ssh;
in
{
  options.betternix.ssh = {
    enable = lib.mkEnableOption "enable betternix packages";
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      betternix.pp
    ];
  };
}
