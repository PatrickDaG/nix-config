{
  lib,
  fetchFromGitHub,
  buildHomeAssistantComponent,
  python3Packages,
}:

buildHomeAssistantComponent rec {
  owner = "Vip0r";
  domain = "varta_storage";
  version = "2025-1-9-unstable";

  src = fetchFromGitHub {
    inherit owner;
    repo = "varta_storage";
    rev = "592cfd8692b24b131cadaa8c6280660fdc262886";
    hash = "sha256-u5VneR7s3V+NjoTnDYPAO2aJeqpDQwPu5Eko5CZQXTw=";
  };

  dependencies = [
    python3Packages.vartastorage
  ];

  meta = with lib; {
    description = "Send notifications with ntfy.sh and selfhosted ntfy-servers";
    homepage = "https://github.com/hbrennhaeuser/homeassistant_integration_ntfy";
    maintainers = with maintainers; [ koral ];
    license = licenses.gpl3;
  };
}
