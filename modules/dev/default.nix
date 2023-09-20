{
  imports = [
    ./docs.nix
  ];
  environment.enableDebugInfo = true;
  services.nixseparatedebuginfod.enable = true;
  environment.shellInit = ''
    gpg-connect-agent /bye
    export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)
    umask 077
  '';
}
