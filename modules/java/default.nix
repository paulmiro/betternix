{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.betternix.java;
in
{
  options.betternix.java = {
    enable = lib.mkEnableOption "enable jdks";
  };

  config = lib.mkIf cfg.enable {

    environment.etc =
      let
        javaToolchains = [
          "${pkgs.jdk11_headless}/lib/openjdk"
        ];
      in
      {
        "bettertec/jdk_8".source = "${pkgs.jdk8_headless}/lib/openjdk";
        "bettertec/jdk_11".source = "${pkgs.jdk11_headless}/lib/openjdk";
        "bettertec/jdk_21".source = "${pkgs.jdk21_headless}/lib/openjdk";
        "bettertec/maven".source = "${pkgs.maven}/maven";
        "bettertec/gradle_8".source = pkgs.gradle_8.override { inherit javaToolchains; };
      };

    environment.systemPackages = with pkgs; [
      jdk8_headless
      jdk11_headless
      jdk21_headless
      maven
      gradle_8
    ];
  };

}
