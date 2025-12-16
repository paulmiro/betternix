{
  imports = map (name: import (../. + "/${name}")) (
    builtins.filter (name: name != "default") (builtins.attrNames (builtins.readDir ../.))
  );
}
