{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.betternix.java;
  javaToolchains = [
    "${pkgs.jdk11}/lib/openjdk"
  ];
  gradle_8 = pkgs.gradle_8.override { inherit javaToolchains; };
in
{
  options.betternix.java = {
    enable = lib.mkEnableOption "enable jdks";
  };

  config = lib.mkIf cfg.enable {

    environment.etc = {
      "bettertec/jdk_11".source = "${pkgs.jdk11}/lib/openjdk";
      "bettertec/jdk_21".source = "${pkgs.jdk21}/lib/openjdk";
      "bettertec/maven".source = "${pkgs.maven}/maven";
      "bettertec/gradle_8".source = gradle_8;
    };

    environment.systemPackages = with pkgs; [
      jdk11
      jdk21
      maven
      gradle_8
    ];
  };

}
