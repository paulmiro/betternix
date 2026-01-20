{
  description = "My NixOS infrastructure";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
  };

  outputs =
    { self, ... }@inputs:
    let
      lib = inputs.nixpkgs.lib;

      supportedSystems = [
        "aarch64-linux"
        "x86_64-linux"
      ];

      forAllSystems = lib.genAttrs supportedSystems;

      nixpkgsFor = forAllSystems (system: import inputs.nixpkgs { inherit system; });

      flakePkgs =
        pkgs:
        (builtins.listToAttrs (
          map (name: {
            inherit name;
            value = pkgs.callPackage (./pkgs + "/${name}") { flake-self = self; };
          }) (builtins.attrNames (builtins.readDir ./pkgs))
        ));

    in
    {
      formatter = forAllSystems (system: nixpkgsFor.${system}.nixfmt-tree);

      packages = forAllSystems (system: flakePkgs nixpkgsFor.${system});

      overlays = {
        betternix-overlay = final: prev: {
          betternix = flakePkgs prev;
        };
      };

      nixosModules = builtins.listToAttrs (
        map (name: {
          inherit name;
          value = (import (./modules + "/${name}"));
        }) (builtins.attrNames (builtins.readDir ./modules))
      );

      homeModules = builtins.listToAttrs (
        map (name: {
          inherit name;
          value = import (./home-modules + "/${name}");
        }) (builtins.attrNames (builtins.readDir ./home-modules))
      );
    };
}
