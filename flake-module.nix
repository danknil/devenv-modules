localFlake: {inputs, ...}: {
  imports = [
    inputs.devenv.flakeModule
  ];
  perSystem = {
    system,
    pkgs,
    ...
  }: {
    _module.args.pkgs = pkgs.extend localFlake.overlays.default;
    devenv.modules = [localFlake.devenvModules.default];
  };
}
