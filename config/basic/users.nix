{
  users.mutableUsers = false;
  users.deterministicIds =
    let
      uidGid = id: {
        uid = id;
        gid = id;
      };
    in
    {
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
      git = uidGid 215;
      vaultwarden = uidGid 215;
      redis-paperless = uidGid 216;
      microvm = uidGid 217;
      maddy = uidGid 218;
      tt_rss = uidGid 219;
      freshrss = uidGid 220;
      mongodb = uidGid 221;
      authelia-main = uidGid 222;
      kanidm = uidGid 223;
      oauth2-proxy = uidGid 224;
      influxdb2 = uidGid 225;
      firefly-iii = uidGid 226;
      homebox = uidGid 227;
      signal = uidGid 228;
      netbird-main = uidGid 229;
      grafana = uidGid 230;
      loki = uidGid 231;
      promtail = uidGid 232;
      telegraf = uidGid 233;
      adguardhome = uidGid 234;
      gamemode = uidGid 235;
      plugdev = uidGid 236;
      firefly-pico = uidGid 237;
      jellyfin = uidGid 238;

      systemd-oom = uidGid 300;
      systemd-coredump = uidGid 301;
      paperless = uidGid 315;
      stalwart-mail = uidGid 316;
      build = uidGid 317;
      nix-build = {
        gid = 330;
      };
      patrick = uidGid 1000;
      smb = uidGid 2000;
      david = uidGid 2004;
      helen = uidGid 2001;
      ggr = uidGid 2002;
      family = uidGid 2003;
      printer = uidGid 2005;
      pr-tracker = uidGid 2006;
      blog = uidGid 2007;
    };
}
