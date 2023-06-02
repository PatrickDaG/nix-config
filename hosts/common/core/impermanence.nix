{
  config,
  lib,
  ...
}: {
  age.identityPaths = ["/state/etc/ssh/ssh_host_ed25519_key"];
  # to allow all users to access hm managed persistent folders
  programs.fuse.userAllowOther = true;
  environment.persistence."/state" = {
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
