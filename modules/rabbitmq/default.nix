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

    systemd.services.rabbitmq.postStart =
      let
        rabbitmqctl = "${pkgs.rabbitmq-server}/bin/rabbitmqctl";
        create-rabbitmq-user = pkgs.writeShellScript "create-rabbitmq-user" ''
          set -euo pipefail

          if [ "$#" -lt 2 ]; then
              echo "usage prepare-web.sh USERNAME PASSWORD [-a]"
              echo "-a makes user an admin-user"
              exit 1
          fi

          USERNAME=$1
          PASSWORD=$2

          ${rabbitmqctl} add_user ''${USERNAME} ''${PASSWORD}
          ${rabbitmqctl} set_permissions ''${USERNAME} ".*" ".*" ".*"

          if [ "$#" -eq 3 ] && [ "$3" == "-a" ]; then
              ${rabbitmqctl} set_user_tags ''${USERNAME} administrator
          fi
        '';
      in
      ''
        set -euo pipefail

        if [ ! -f ${config.services.rabbitmq.dataDir}/.bettertec-init-done ]; then
          ${pkgs.rabbitmq-server}/bin/rabbitmqctl delete_user guest

          export CREATE_USER=${create-rabbitmq-user}
          ${pkgs.bash}/bin/bash ${config.sops.secrets."scripts/init-rabbitmq-users.sh".path}

          touch ${config.services.rabbitmq.dataDir}/.bettertec-init-done
        else
          echo "rabbitmq is already initialized"
        fi
      '';

    # TODO: this doesn't work of course
    sops.secrets."scripts/init-rabbitmq-users.sh" = {
      mode = "0400";
      owner = config.users.users.rabbitmq.name;
      group = config.users.groups.rabbitmq.name;
      path = "/etc/bettertec/scripts/create-rabbit-users.sh";
    };
  };
}
