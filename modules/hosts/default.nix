{
  config,
  lib,
  ...
}:
let
  cfg = config.betternix.hosts;
in
{
  options.betternix.hosts = {
    enable = lib.mkEnableOption "enable hosts";
  };

  config = lib.mkIf cfg.enable {
    networking.hostFiles = [ ./hosts ];
  };
}
