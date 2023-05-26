{
  config,
  lib,
  ...
}: {
  age.identityPaths = ["/persist/etc/ssh/ssh_host_ed25519_key"];
  environment.persistence."/persist" = {
    hideMounts = true;

    files = [
      "/etc/machine-id"
      "/etc/ssh/ssh_host_ed25519_key"
      "/etc/ssh/ssh_host_ed25519_key.pub"
    ];
    directories = [
      {
        directory = "/var/lib/nixos";
        user = "root";
        group = "root";
        mode = "0775";
      }
    ];
  };
}
