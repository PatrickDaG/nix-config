{
  lib,
  python3Packages,
  fetchFromGitHub,
}:

python3Packages.buildPythonPackage rec {
  pname = "vartastorage";
  version = "2025.1.9";

  disabled = python3Packages.pythonOlder "3.12";

  src = fetchFromGitHub {
    owner = "Vip0r";
    repo = "vartastorage";
    rev = "5e24b25dbafeabceefd513001f3b8b6a598463a1";
    hash = "sha256-8eZOTQUbv7ing05aIYYJcP3zfLc91plC7QNqM7a3ZZQ=";
  };

  __darwinAllowLocalNetworking = true;

  build-system = [ ];

  dependencies = [
  ];

  nativeCheckInputs = [
  ];

  meta = with lib; {
    description = "Python module to interact with HomeMatic devices";
    homepage = "https://github.com/SukramJ/hahomematic";
    changelog = "https://github.com/SukramJ/hahomematic/blob/${src.tag}/changelog.md";
    license = licenses.mit;
    maintainers = with maintainers; [
      dotlambda
      fab
    ];
  };
}
