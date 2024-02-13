{
  users.mutableUsers = false;
  users.deterministicIds = let
    uidGid = id: {
      uid = id;
      gid = id;
    };
  in {
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
    podman = uidGid 211;
    acme = uidGid 212;
    nextcloud = uidGid 213;
    redis-nextcloud = uidGid 214;
    radicale = uidGid 215;
    gitea = uidGid 215;
    vaultwarden = uidGid 215;
    redis-paperless = uidGid 216;
    microvm = uidGid 217;
    maddy = uidGid 218;
    tt_rss = uidGid 219;
    paperless = uidGid 315;
    systemd-oom = uidGid 300;
    systemd-coredump = uidGid 301;
    patrick = uidGid 1000;
    smb = uidGid 2000;
    david = uidGid 2004;
    helen = uidGid 2001;
    ggr = uidGid 2002;
    family = uidGid 2003;
  };
}
