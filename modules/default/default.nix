{
  imports = map (name: import (./modules + "/${name}")) (
    builtins.filter (name: name != "default") (builtins.attrNames (builtins.readDir ./modules))
  );
}
