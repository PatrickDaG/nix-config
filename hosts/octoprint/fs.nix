{lib, ...}: {
  fileSystems = lib.mkForce {
    "/" = {
      device = "/dev/disk/by-uuid/44444444-4444-4444-8888-888888888888";
      fsType = "ext4";
    };
  };
  environment.persistence = lib.mkForce {};
}
