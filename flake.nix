{
  description = "DankNil's modules for devenv and overlay for dev packages";

  inputs = {
    devenv-root = {
      url = "file+file:///dev/null";
      flake = false;
    };
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    de.url = "github:cachix/devenv";
    flake-parts.url = "github:hercules-ci/flake-parts";
    nix2container = {
      url = "github:nlewo/nix2container";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  nixConfig = {
    extra-trusted-public-keys = "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw=";
    extra-substituters = "https://devenv.cachix.org";
  };

  outputs = {
    flake-parts,
    devenv-root,
    ...
  } @ inputs:
    flake-parts.lib.mkFlake {inherit inputs;} {
      systems = ["x86_64-linux" "i686-linux" "x86_64-darwin" "aarch64-linux" "aarch64-darwin"];

      imports = [
        inputs.de.flakeModule
        inputs.flake-parts.flakeModules.easyOverlay
      ];

      flake.devenvModules = import ./modules;

      perSystem = {
        config,
        self',
        inputs',
        pkgs,
        system,
        ...
      }: {
        packages = import ./packages pkgs;

        overlayAttrs = {
          inherit (config.packages) tomcat7;
        };

        devenv.shells.default = {
          # devenv.root = let
          #   devenvRootFileContent = builtins.readFile devenv-root.outPath;
          # in
          #   pkgs.lib.mkIf (devenvRootFileContent != "") devenvRootFileContent;
          packages = [pkgs.hello];

          enterShell = ''
            hello
          '';
        };
      };
    };
}
