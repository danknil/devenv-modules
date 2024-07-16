{
  version,
  src,
}: {
  lib,
  stdenvNoCC,
  fetchurl,
  nixosTests,
  testers,
  jre,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "apache-tomcat";
  inherit version src;

  outputs = ["out" "webapps"];
  installPhase = ''
    mkdir $out
    mv * $out
    mkdir -p $webapps/webapps
    mv $out/webapps $webapps/
  '';

  passthru.tests = {
    inherit (nixosTests) tomcat;
    version = testers.testVersion {
      package = finalAttrs.finalPackage;
      command = "JAVA_HOME=${jre} ${finalAttrs.finalPackage}/bin/version.sh";
    };
  };

  meta = with lib; {
    homepage = "https://tomcat.apache.org/";
    description = "Implementation of the Java Servlet and JavaServer Pages technologies";
    inherit (jre.meta) platforms;
    maintainers = with maintainers; [anthonyroussel];
    license = [licenses.asl20];
    sourceProvenance = with sourceTypes; [binaryBytecode];
  };
})
