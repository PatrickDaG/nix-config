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
  environment.systemPackages = with pkgs; [
    gnumake
    pciutils
    gcc
    usbutils
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
