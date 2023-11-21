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
    rtkit = uidGid 204;
    nixseparatedebuginfod = uidGid 205;
    wireshark = uidGid 206;
    polkituser = uidGid 207;
    msr = uidGid 208;
    avahi = uidGid 209;
    fwupd-refresh = uidGid 210;
    systemd-oom = uidGid 300;
    systemd-coredump = uidGid 301;
  };
}
