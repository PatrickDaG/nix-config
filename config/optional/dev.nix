{
  lib,
  minimal,
  pkgs,
  ...
}:
lib.optionalAttrs (!minimal) {
  environment.systemPackages = with pkgs; [
    python3
    jq
    nix-update
    gnumake
    pciutils
    gcc
    usbutils
    man-pages
    man-pages-posix
  ];

  services.nixseparatedebuginfod.enable = true;
  environment = {
    enableDebugInfo = true;
    shellInit = ''
      gpg-connect-agent /bye
      export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)
      umask 077
    '';
  };
  documentation = {
    dev.enable = true;
    man.enable = true;
    info.enable = false;
  };
}
