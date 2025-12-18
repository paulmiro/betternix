{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.betternix.java;
  javaToolchains = [
    "${pkgs.jdk11_headless}/lib/openjdk"
  ];
  gradle = pkgs.gradle_8.override { inherit javaToolchains; };
in
{
  options.betternix.java = {
    enable = lib.mkEnableOption "enable jdks";
  };

  config = lib.mkIf cfg.enable {

    environment.etc = {
      "bettertec/jdk_11".source = "${pkgs.jdk11_headless}/lib/openjdk";
      "bettertec/jdk_21".source = "${pkgs.jdk21_headless}/lib/openjdk";
      "bettertec/maven".source = "${pkgs.maven}/maven";
      "bettertec/gradle_8".source = gradle;
    };

    environment.systemPackages = with pkgs; [
      jdk11_headless
      jdk21_headless
      maven
      gradle
    ];
  };

}
