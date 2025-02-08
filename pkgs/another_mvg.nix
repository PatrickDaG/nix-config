{
  lib,
  fetchFromGitHub,
  buildHomeAssistantComponent,
}:

buildHomeAssistantComponent rec {
  owner = "Nisbo";
  domain = "another_mvg";
  version = "2.1.0";

  src = fetchFromGitHub {
    owner = "Nisbo";
    repo = "another_mvg";
    tag = "v${version}";
    hash = "sha256-p00YD37sKOJ0oOTGYZgKZeQaxx96FqDPeCnBkdoizcY=";
  };

  meta = with lib; {
    description = "Custom component for Home Assistant that integrates weather data (measurements and forecasts) of Deutscher Wetterdienst";
    homepage = "https://github.com/hg1337/homeassistant-dwd";
    license = licenses.asl20;
    maintainers = with maintainers; [
      hexa
      emilylange
    ];
  };
}
