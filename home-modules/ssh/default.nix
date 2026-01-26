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
      matchBlocks = {
        "betterbuild" = {
          hostname = "betterbuild";
          user = "bettertec";
        };
        "git.bettertec.internal" = {
          hostname = "git.bettertec.internal";
          user = "forgejo";
        };
        "betterdev-*" = {
          extraOptions = {
            IdentityFile = "~/.ssh/betterkey";
            user = "bettertec";
          };
        };
        "bettertec-*" = {
          extraOptions = {
            IdentityFile = "~/.ssh/betterkey";
            user = "bettertec";
          };
        };
        "bettertest-*" = {
          extraOptions = {
            IdentityFile = "~/.ssh/betterkey";
            user = "bettertec";
          };
        };
        "nce-*" = {
          extraOptions = {
            IdentityFile = "~/.ssh/betterkey";
            user = "bettertec";
          };
        };
        "ncetest-*" = {
          extraOptions = {
            IdentityFile = "~/.ssh/betterkey";
            user = "bettertec";
          };
        };
      };
    };
  };
}
