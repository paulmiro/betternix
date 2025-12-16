{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.betternix.trusted-certificates;

  caBundle = config.security.pki.caBundle;
  p11kit = pkgs.p11-kit.overrideAttrs (oldAttrs: {
    mesonFlags = [
      "--sysconfdir=/etc"
      (lib.mesonEnable "systemd" false)
      (lib.mesonOption "bashcompdir" "${placeholder "bin"}/share/bash-completion/completions")
      (lib.mesonOption "trust_paths" (
        lib.concatStringsSep ":" [
          "${caBundle}"
        ]
      ))
    ];
  });
  javaCaCerts = derivation {
    name = "java-cacerts";
    builder = pkgs.writeShellScript "java-cacerts-builder" ''
      ${p11kit.bin}/bin/trust \
        extract \
        --format=java-cacerts \
        --purpose=server-auth \
        $out
    '';
    system = pkgs.hostPlatform.system;
    outputs = [ "out" ];
  };
in
{
  options.betternix.trusted-certificates = {
    enable = lib.mkEnableOption "enable trusting custom certificates";
    enableJava = lib.mkOption {
      description = "enable trusting custom certificates for java";
      type = lib.types.bool;
      default = true;
    };
  };

  config = lib.mkIf cfg.enable {

    security.pki.certificates = [
      (builtins.readFile ./bettertec-ca-cert.pem)
    ];

    environment.variables = lib.mkIf cfg.enableJava {
      # requires a patched version of openjdk
      # (openjdk is already patched, see https://github.com/NixOS/nixpkgs/blob/master/pkgs/development/compilers/openjdk/11/patches/read-truststore-from-env-jdk10.patch)
      JAVAX_NET_SSL_TRUSTSTORE = javaCaCerts.outPath;
    };

    environment.etc."bettertec/certs/java-cacerts".source = javaCaCerts.outPath;
    environment.etc."bettertec/certs/bettertec-ca-cert.pem".source = ./bettertec-ca-cert.pem;

  };
}
