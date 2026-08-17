{ lib, ... }:
{
  imports = map (name: import (../. + "/${name}")) (
    builtins.filter (name: name != "default") (builtins.attrNames (builtins.readDir ../.))
  );

  options.betternix = {
    username = lib.mkOption {
      description = "Default user for various betternix services";
      type = lib.types.str;
      default = null;
    };
  };
}
