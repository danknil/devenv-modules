{
  lib,
  callPackage,
  fetchurl,
  ...
}: let
  tomcat = {
    version,
    src,
  }:
    callPackage (import ./tomcat.nix {
      inherit version src;
    }) {};
in {
  tomcat7 = tomcat rec {
    version = "7.0.109";
    src = fetchurl {
      url = "https://archive.apache.org/dist/tomcat/tomcat-${lib.version.major version}/v${version}/bin/apache-tomcat-${version}.tar.gz";
      hash = "";
    };
  };
}
