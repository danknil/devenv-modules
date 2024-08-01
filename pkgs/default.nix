{
  callPackage,
  callPackages,
  fetchurl,
  lib,
  ...
}: let
in {
  inherit (callPackages (import ./tomcat.nix) {}) tomcat7;
}
