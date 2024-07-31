{
  description = "DankNil's modules for devenv and overlay for dev packages";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    devenv.url = "github:cachix/devenv";

    # System list
    systems.url = "github:nix-systems/default";
  };

  nixConfig = {
    extra-trusted-public-keys = "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw=";
    extra-substituters = "https://devenv.cachix.org";
  };

  outputs = {
    self,
    nixpkgs,
    devenv,
    systems,
    ...
  } @ inputs: let
    inherit (self) outputs;
    inherit (nixpkgs) lib;

    forAllSystems = nixpkgs.lib.genAttrs (import systems);
  in {
    # Your custom packages
    # Accessible through 'nix build', 'nix shell', etc
    packages = forAllSystems (system: import ./pkgs nixpkgs.legacyPackages.${system});

    # Formatter for your nix files, available through 'nix fmt'
    # Other options beside 'alejandra' include 'nixpkgs-fmt'
    formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.alejandra);

    # Your custom packages and modifications, exported as overlays
    overlays = {
      # This one brings our custom packages from the 'pkgs' directory
      default = final: _prev: {
        custom = import ./pkgs final.pkgs;
      };
    };


    # my devenv modules
    devenvModules = import ./modules;

    # default shell for development
    devShells = forAllSystems (system: {
      default = inputs.devenv.lib.mkShell {
        inherit inputs;
        pkgs = nixpkgs.legacyPackages.${system};
        modules = [
          ({
            pkgs,
            config,
            ...
          }: {
            packages = [pkgs.git];
            languages.nix.enable = true;
            pre-commit.hooks.alejandra = {
              enable = true;
              fail_fast = true;
            };
          })
        ];
      };
    });
  };
}
