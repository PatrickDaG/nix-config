{
  config,
  lib,
  # globals,
  ...
}:
{
  disko.devices = {
    disk = {
      internal-ssd = rec {
        type = "disk";
        device = "/dev/disk/by-id/${config.secrets.secrets.local.disko.nvme}";
        content = with lib.disko.gpt; {
          type = "gpt";
          partitions = {
            boot = (partEfi "1GiB") // {
              device = "${device}-part1";
            };
            rpool = (partLuksZfs "ssd" "rpool" "100%") // {
              device = "${device}-part2";
            };
          };
        };
      };
      "4TB-hdd-1" = {
        type = "disk";
        device = "/dev/disk/by-id/${config.secrets.secrets.local.disko."4TB-1"}";
        content = lib.disko.content.luksZfs "hdd-4TB-1" "renaultft";
      };
      "4TB-hdd-2" = {
        type = "disk";
        device = "/dev/disk/by-id/${config.secrets.secrets.local.disko."4TB-2"}";
        content = lib.disko.content.luksZfs "hdd-4TB-2" "renaultft";
      };
      "4TB-hdd-3" = {
        type = "disk";
        device = "/dev/disk/by-id/${config.secrets.secrets.local.disko."4TB-3"}";
        content = lib.disko.content.luksZfs "hdd-4TB-3" "renaultft";
      };
      "8TB-hdd-1" = {
        type = "disk";
        device = "/dev/disk/by-id/${config.secrets.secrets.local.disko."8TB-1"}";
        content = lib.disko.content.luksZfs "hdd-8TB-1" "panzer";
      };
      "8TB-hdd-2" = {
        type = "disk";
        device = "/dev/disk/by-id/${config.secrets.secrets.local.disko."8TB-2"}";
        content = lib.disko.content.luksZfs "hdd-8TB-2" "panzer";
      };
      "8TB-hdd-3" = {
        type = "disk";
        device = "/dev/disk/by-id/${config.secrets.secrets.local.disko."8TB-3"}";
        content = lib.disko.content.luksZfs "hdd-8TB-3" "panzer";
      };
    };

    zpool = with lib.disko.zfs; {
      rpool = mkZpool { datasets = impermanenceZfsDatasets; };
      panzer = mkZpool {
        datasets = {
          "safe/guests" = unmountable;
        };
        mode = "raidz";
      };
      renaultft = mkZpool {
        datasets = {
          "safe/guests" = unmountable;
        };
        mode = "raidz";
      };
    };
  };

  boot.kernel.sysctl."fs.inotify.max_user_instances" = 1024;

  services.zrepl = {
    enable = true;
    settings = {
      global = {
        logging = [
          {
            type = "syslog";
            level = "info";
            format = "human";
          }
        ];
        # TODO Monitoring
      };
      jobs = [
        #{
        #  type = "push";
        #  name = "push-to-remote";
        #}
        {
          type = "snap";
          name = "mach-schnipp-schusss";
          filesystems = {
            "panzer<" = true;
            "rpool/local/state<" = true;
            "rpool/local/guests<" = true;
            "rpool/safe<" = true;
            "renaultft<" = true;
          };
          snapshotting = {
            type = "periodic";
            prefix = "zrepl-";
            interval = "10m";
            timestamp_format = "iso-8601";
          };
          pruning = {
            keep = [
              {
                type = "regex";
                regex = "^zrepl-.*$";
                negate = true;
              }
              {
                type = "grid";
                grid = lib.concatStringsSep " | " [
                  "1x1d(keep=all)"
                  "142x1h(keep=2)"
                  "90x1d(keep=2)"
                  "500x7d"
                ];
                regex = "^zrepl-.*$";
              }
            ];
          };
        }
      ];
    };
  };

  wireguard.scrtiny-patrick.server = {
    #host = globals.domains.web;
    host = "3.3.3.3";
    port = 51831;
    reservedAddresses = [
      "10.44.0.0/16"
      "fd00:1766::/112"
    ];
    openFirewall = true;
  };
  networking.nftables.firewall.zones.untrusted.interfaces = [ "scrtiny-patrick" ];
  services.scrutiny = {
    enable = true;
    openFirewall = true;
    collector = {
      enable = true;
      settings.host.id = "elisabeth";
    };
  };
  environment.persistence."/persist".directories = [
    {
      directory = "/var/lib/influxdb2";
      mode = "0700";
      user = "influxdb2";
    }
  ];
  environment.persistence."/state".directories = [
    {
      directory = "/var/lib/private/scrutiny";
      mode = "0700";
    }
  ];

  fileSystems."/state".neededForBoot = true;
  fileSystems."/persist".neededForBoot = true;
  boot.initrd.systemd.services."zfs-import-panzer".after = [ "cryptsetup.target" ];
  boot.initrd.systemd.services."zfs-import-renaultft".after = [ "cryptsetup.target" ];
  systemIdentity = {
    enable = true;
  };
}
