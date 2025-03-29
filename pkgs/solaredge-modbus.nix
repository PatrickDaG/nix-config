{
  lib,
  fetchFromGitHub,
  buildHomeAssistantComponent,
  pymodbus,
}:

buildHomeAssistantComponent rec {
  owner = "binsentsu";
  domain = "solaredge_modbus";
  version = "2.0.3";

  src = fetchFromGitHub {
    inherit owner;
    repo = "home-assistant-solaredge-modbus";
    tag = "V${version}";
    hash = "sha256-Cb2/zeq+66xAjo6HYhDLxTOc6u/z4pAx1GrwTPB3Isk=";
  };
  dependencies = [
    pymodbus
  ];
  # don't check the version constraint of pyemvue
  ignoreVersionRequirement = [
    "pymodbus"
  ];

  meta = with lib; {
    homepage = "https://github.com/hg1337/homeassistant-dwd";
    license = licenses.asl20;
    maintainers = with maintainers; [
      hexa
      emilylange
    ];
  };
}
