{
  users.mutableUsers = false;
  users.deterministicIds = let
    uidGid = id: {
      uid = id;
      gid = id;
    };
  in {
    smb = uidGid 200;
    nscd = uidGid 201;
    sshd = uidGid 202;
    tss = uidGid 203;
    polkituser = uidGid 204;
    systemd-oom = uidGid 300;
    systemd-coredump = uidGid 301;
  };
}
