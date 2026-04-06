{
  lib,
  fetchFromGitHub,
  buildHomeAssistantComponent,
}:

buildHomeAssistantComponent rec {
  owner = "Nisbo";
  domain = "another_mvg";
  version = "2.2.0.BETA.5";

  src = fetchFromGitHub {
    owner = "Nisbo";
    repo = "another_mvg";
    tag = "v${version}";
    hash = "sha256-zmq0S3zN7mJCk8sUIfdaZvtqTHXjqC4OFqHr9MgiOto=";
  };
}
