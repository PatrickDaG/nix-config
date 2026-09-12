{
  lib,
  fetchFromGitHub,
  buildHomeAssistantComponent,
  beautifulsoup4,
}:
buildHomeAssistantComponent rec {
  owner = "greghesp";
  domain = "bambu_lab";
  version = "2.3.0";

  src = fetchFromGitHub {
    inherit owner;
    repo = "ha-bambulab";
    tag = "v${version}";
    hash = "sha256-FqN+CKS17fv3f3AoqUxEGhjLXvTIWRcDPmrOHWLEpiI=";
  };

  dependencies = [ beautifulsoup4 ];

  meta = {
    description = "Bambu Lab integration for Home Assistant";
    homepage = "https://github.com/greghesp/ha-bambulab";
    license = lib.licenses.mit;
  };
}
