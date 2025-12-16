{
  rabbitmq-server,
  writeShellScriptBin,
  ...
}:
let
  rabbitmqctl = "${rabbitmq-server}/bin/rabbitmqctl";
in
writeShellScriptBin "create-rabbitmq-user" ''
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
''
