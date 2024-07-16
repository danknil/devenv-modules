rec {
  tomcat = ./tomcat.nix;
  default = _: {
    imports = [
      tomcat
    ];
  };
}
