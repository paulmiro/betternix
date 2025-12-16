{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.betternix.rabbitmq;
in
{
  options.betternix.rabbitmq = {
    enable = lib.mkEnableOption "enable rabbitmq and create users";
  };

  config = lib.mkIf cfg.enable {
    services.rabbitmq = {
      enable = true;
      plugins = [
        "rabbitmq_shovel"
        "rabbitmq_management"
      ];
    };

    systemd.services.rabbitmq.postStart = ''
      set -euo pipefail

      if [ ! -f ${config.services.rabbitmq.dataDir}/.bettertec-init-done ]; then
        ${pkgs.rabbitmq-server}/bin/rabbitmqctl delete_user guest

        export CREATE_USER=${pkgs.betternix.create-rabbitmq-user}/bin/create-rabbitmq-user
        ${pkgs.bash}/bin/bash ${config.sops.secrets."scripts/init-rabbitmq-users.sh".path}

        touch ${config.services.rabbitmq.dataDir}/.bettertec-init-done
      else
        echo "rabbitmq is already initialized"
      fi
    '';

    sops.secrets."scripts/init-rabbitmq-users.sh" = {
      mode = "0400";
      owner = config.users.users.rabbitmq.name;
      group = config.users.groups.rabbitmq.name;
      path = "/etc/bettertec/scripts/create-rabbit-users.sh";
    };
  };
}
