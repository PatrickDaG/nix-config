{
  lib,
  minimal,
  pkgs,
  ...
}:
lib.optionalAttrs (!minimal) {
  imports = [
    ./docs.nix
  ];
  programs.wireshark = {
    enable = true;
    package = pkgs.wireshark;
  };
  services.nixseparatedebuginfod.enable = true;
  environment = {
    enableDebugInfo = true;
    shellInit = ''
      gpg-connect-agent /bye
      export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)
      umask 077
    '';
  };
}
