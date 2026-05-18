{ lib
, buildNpmPackage
, fetchFromGitLab
}:

buildNpmPackage rec {
  pname = "html-validate";
  version = "11.2.0";

  src = fetchFromGitLab {
    owner = "html-validate";
    repo = "html-validate";
    rev = "v${version}";
    sha256 = "1350c231bngbv2a2nwxnpncxc135r357p91wx5nk7cfcks7hf5d2";
  };

  npmDepsHash = "sha256-sGZpSCQuk64OV83oALJ0tXSDM741M3D7ttSMvOsPBLc=";

  npmInstallFlags = [ "--ignore-scripts" ];
  dontNpmPrune = true;
  dontCheckForBrokenSymlinks = true;
}
