{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.betternix.azure-vpn;
in
{
  options.betternix.azure-vpn = {
    enable = lib.mkEnableOption "Azure VPN";
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = config.betternix.username != null;
        message = "betternix.username must be set for azure-vpn to work";
      }
      {
        assertion = config.networking.networkmanager.enable;
        message = "NetworkManager must be enabled for azure-vpn to work. set config.networking.networkmanager.enable = true;";
      }
    ];

    networking.networkmanager = {
      plugins = [
        pkgs.networkmanager-strongswan
      ];
      ensureProfiles.profiles."Azure IKEv2" = {
        connection = {
          autoconnect = "false";
          id = "Azure IKEv2";
          permissions = "user:${config.betternix.username}:;";
          type = "vpn";
          uuid = "de6df8de-0a8c-442c-ae80-0734c5d36d77";
        };
        ipv4 = {
          method = "auto";
          never-default = "true";
        };
        ipv6 = {
          addr-gen-mode = "default";
          method = "auto";
          never-default = "true";
        };
        proxy = { };
        vpn = {
          address = "azuregateway-b42f0069-2ac0-45d9-8a60-cb46bf0c2a24-bd460020cefe.vpn.azure.com";
          cert-source = "file";
          certificate = config.sops.secrets."VpnServerRoot.cer".path;
          encap = "no";
          ipcomp = "no";
          method = "cert";
          password-flags = "2";
          proposal = "no";
          service-type = "org.freedesktop.NetworkManager.strongswan";
          usercert = config.sops.secrets."azure-vpn/azure.crt".path;
          userkey = config.sops.secrets."azure-vpn/azure.key".path;
          virtual = "yes";
        };
      };
    };

    sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
    sops.secrets = {
      "VpnServerRoot.cer" = {
        sopsFile = ../../secrets/VpnServerRoot.cer;
        format = "binary";
        mode = "0400";
        owner = config.betternix.username;
        path = "/etc/bettertec/azure-vpn/VpnServerRoot.cer";
      };
      "azure-vpn/azure.crt" = {
        sopsFile = ../../secrets/secrets.yaml;
        mode = "0400";
        owner = config.betternix.username;
        path = "/etc/bettertec/azure-vpn/azure.crt";
      };
      "azure-vpn/azure.key" = {
        sopsFile = ../../secrets/secrets.yaml;
        mode = "0400";
        owner = config.betternix.username;
        path = "/etc/bettertec/azure-vpn/azure.key";
      };
    };

    services.strongswan.enable = true;

    # strongswan refuses to start without this file present
    environment.etc."strongswan.conf".text = lib.mkDefault "";
  };
}
