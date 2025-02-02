{
  fetchurl,
  gitUpdater,
  jre,
  lib,
  nixosTests,
  stdenvNoCC,
  testers,
}: let
  common = {
    version,
    hash,
  }:
    stdenvNoCC.mkDerivation (finalAttrs: {
      pname = "apache-tomcat";
      inherit version;

      src = fetchurl {
        url = "mirror://apache/tomcat/tomcat-${lib.versions.major version}/v${version}/bin/apache-tomcat-${version}.tar.gz";
        inherit hash;
      };

      outputs = [
        "out"
        "webapps"
      ];
      installPhase = ''
        mkdir $out
        mv * $out
        mkdir -p $webapps/webapps
        mv $out/webapps $webapps/
      '';

      passthru = {
        updateScript = gitUpdater {
          url = "https://github.com/apache/tomcat.git";
          allowedVersions = "^${lib.versions.major version}\\.";
          ignoredVersions = "-M.*";
        };
        tests = {
          inherit (nixosTests) tomcat;
          version = testers.testVersion {
            package = finalAttrs.finalPackage;
            command = "JAVA_HOME=${jre} ${finalAttrs.finalPackage}/bin/version.sh";
          };
        };
      };

      meta = {
        homepage = "https://tomcat.apache.org/";
        description = "Implementation of the Java Servlet and JavaServer Pages technologies";
        platforms = jre.meta.platforms;
        maintainers = with lib.maintainers; [anthonyroussel];
        license = lib.licenses.asl20;
        sourceProvenance = with lib.sourceTypes; [binaryBytecode];
      };
    });
in {
  tomcat7 = common {
    version = "7.0.109";
    hash = "sha256-6/6wUebaJLzlg6QQVDm/2v79x8W91kLbKrB+BWIRyzE=";
  };
}
