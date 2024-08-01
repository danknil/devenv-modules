{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.services.tomcat;
in {
  options.services.tomcat = {
    enable = lib.mkEnableOption "Enable tomcat";
    package = lib.mkPackageOption pkgs "custom.tomcat7" {
      example = "tomcat10";
    };
    baseDir = lib.mkOption {
      type = lib.types.path;
      default = "$DEVENV_ROOT/tomcat";
      description = ''
        Location where Tomcat stores configuration files, web applications
        and logfiles. Note that it is partially cleared on each service startup
        if `purifyOnStart` is enabled.
      '';
    };
    jdk = lib.mkPackageOption pkgs "jdk" {};
    javaOpts = lib.mkOption {
      type = lib.types.either (lib.types.listOf lib.types.str) lib.types.str;
      default = "";
      description = "Parameters to pass to the Java Virtual Machine which spawns Apache Tomcat";
    };

    catalinaOpts = lib.mkOption {
      type = lib.types.either (lib.types.listOf lib.types.str) lib.types.str;
      default = "";
      description = "Parameters to pass to the Java Virtual Machine which spawns the Catalina servlet container";
    };
  };

  config = lib.mkIf cfg.enable {
    packages = with cfg; [package jdk];
    env = {
      CATALINA_BASE = "${cfg.baseDir}";
      CATALINA_PID = "/run/tomcat/tomcat.pid";
      JAVA_HOME = "${cfg.jdk}";
      JAVA_OPTS = "${builtins.toString cfg.javaOpts}";
      CATALINA_OPTS = "${builtins.toString cfg.catalinaOpts}";
    };
  };
}
