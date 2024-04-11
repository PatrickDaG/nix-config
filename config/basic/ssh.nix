{lib, ...}: {
  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      PermitRootLogin = "yes";
    };
    startWhenNeeded = lib.mkForce false;
    hostKeys = [
      {
        # never set this to an actual nix type path
        # or else .....
        # it will end up in the nix store
        path = "/etc/ssh/ssh_host_ed25519_key";
        type = "ed25519";
      }
    ];
  };
}
