{
  config,
  lib,
  ...
}:
let
  cfg = config.betternix.ssh;
in
{
  options.betternix.ssh = {
    enable = lib.mkEnableOption "enable ssh stuff";
  };

  config = lib.mkIf cfg.enable {
    programs.ssh.matchBlocks = {
      "betterbuild" = {
        hostname = "betterbuild";
        user = "bettertec";
      };
      "git.bettertec.internal" = {
        hostname = "git.bettertec.internal";
        user = "forgejo";
      };
    };
  };
}
