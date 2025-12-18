{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.betternix.postgresql;
in
{
  options.betternix.postgresql = {
    enable = lib.mkEnableOption "enable postgresql and create database and users";
  };

  config = lib.mkIf cfg.enable {
    services.postgresql = {
      enable = true;
      enableTCPIP = true;
      package = pkgs.postgresql_16;
      ensureDatabases = [
        "betterbuild"
        "build_rest"
        "build_loader"
        "build_export"
      ];
      ensureUsers = [
        {
          name = "bettertec";
          ensureClauses = {
            superuser = true;
          };
        }
      ]
      ++ (map (name: { inherit name; }) [
        "badmin"
        "base"
        "denorm"
        "export"
        "forward"
        "id"
        "loader"
        "monitor"
        "readonly"
        "report"
        "rest"
        "tomcat"
        "track"
      ]);
      # mkForce to turn off the default values
      authentication = lib.mkForce ''
        #type  database  DBuser      origin-address  auth-method
        local  all       all         trust
        # ipv4
        host   all       postgres    127.0.0.1/32    trust
        host   all       bettertec   127.0.0.1/32    trust
        host   all       all         127.0.0.1/32    md5
        # ipv6
        host   all       postgres    ::1/128         trust
        host   all       bettertec   ::1/128         trust
        host   all       all         ::1/128         md5
      '';
    };

    sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
    sops.secrets."scripts/alter-users-psql.sql" = {
      sopsFile = ../../secrets/secrets.yaml;
      mode = "0400";
      owner = config.users.users.postgres.name;
      group = config.users.groups.postgres.name;
      path = "/etc/bettertec/scripts/alter-users-psql.sql";
    };

    systemd.services.postgresql-setup.script =
      let
        dbOwnerScript = pkgs.writeText "postgres-ensure-db-owner.sql" ''
          ALTER DATABASE "betterbuild" OWNER TO "bettertec";
          ALTER DATABASE "build_rest" OWNER TO "bettertec";
          ALTER DATABASE "build_loader" OWNER TO "bettertec";
          ALTER DATABASE "build_export" OWNER TO "bettertec";
        '';
      in
      lib.mkAfter ''
        psql -tAf "${dbOwnerScript}" -d postgres
        psql -tAf "${config.sops.secrets."scripts/alter-users-psql.sql".path}" -d postgres
      '';
  };
}
