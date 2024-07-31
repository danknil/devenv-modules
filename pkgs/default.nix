{...}: let
  tomcat = import ./tomcat.nix;
in {
  inherit (tomcat) tomcat7;
}
