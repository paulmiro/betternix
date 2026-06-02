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
    programs.ssh = {
      enable = true;
      settings = {
        "betterbuild" = {
          hostname = "betterbuild";
          user = "bettertec";
        };
        "git.bettertec.internal" = {
          hostname = "git.bettertec.internal";
          user = "forgejo";
        };
        "betterdev-*" = {
          IdentityFile = "~/.ssh/betterkey";
          user = "bettertec";
        };
        "bettertec-*" = {
          IdentityFile = "~/.ssh/betterkey";
          user = "bettertec";
        };
        "bettertest-*" = {
          IdentityFile = "~/.ssh/betterkey";
          user = "bettertec";
        };
        "nce-*" = {
          IdentityFile = "~/.ssh/betterkey";
          user = "bettertec";
        };
        "ncetest-*" = {
          IdentityFile = "~/.ssh/betterkey";
          user = "bettertec";
        };
      };
    };
  };
}
