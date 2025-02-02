{
  description = "DankNil's modules for devenv and overlay for dev packages";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    devenv.url = "github:cachix/devenv";
  };

  nixConfig = {
    extra-trusted-public-keys = "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw=";
    extra-substituters = "https://devenv.cachix.org";
  };

  outputs = {
    flake-parts,
    devenv,
    ...
  } @ inputs:
    flake-parts.lib.mkFlake {inherit inputs;} ({
      withSystem,
      flake-parts-lib,
      ...
    }: let
      inherit (flake-parts-lib) importApply;
      flakeModules.default = importApply ./flake-module.nix {inherit withSystem;};
    in {
      imports = [
        devenv.flakeModule
        flakeModules.default
        flake-parts.flakeModules.easyOverlay
      ];

      systems = [
        # systems for which you want to build the `perSystem` attributes
        "x86_64-linux"
        # ...
      ];

      flake = {
        devenvModules = import ./modules;
        inherit flakeModules;
      };

      perSystem = {
        config,
        pkgs,
        final,
        ...
      }: {
        formatter = pkgs.alejandra;

        packages = import ./pkgs pkgs;

        overlayAttrs = {
          inherit (config.packages) tomcat7;
        };

        devenv.shells.default = {
          containers = pkgs.lib.mkForce {};
          packages = [final.tomcat7];
          languages.nix.enable = true;
          pre-commit.hooks.alejandra = {
            enable = true;
            fail_fast = true;
          };
        };
      };
    });
}
