{config, ...}: {
  services.samba-wsdd.enable = true; # make shares visible for windows 10 clients
  networking.firewall.allowedTCPPorts = [
    5357 # wsdd
  ];
  networking.firewall.allowedUDPPorts = [
    3702 # wsdd
  ];
  services.samba = {
    enable = true;
    securityType = "user";
    openFirewall = true;
    extraConfig = ''
      logging = systemd
      log level = 0 auth:2 passdb:2
      hosts allow = 192.168.178. 127.0.0.1 10.0.0. localhost
      hosts deny = 0.0.0.0/0
      guest account = nobody
      map to guest = bad user
      passdb backend = tdbsam:${config.age.secrets.smbpassdb.path}
      server role = standalone
    '';
    shares = {
      ggr-data = {
        path = /media/smb/ggr-data;
        "read only" = "no";
        "guest ok" = "no";
        "create mask" = "0640";
        "directory mask" = "0750";
        "force user" = "smb";
        "force group" = "smb";
        "valid users" = "smb";
      };
      patri-data = {
        path = /media/smb/patri-data;
        "read only" = "no";
        "guest ok" = "no";
        "create mask" = "0640";
        "directory mask" = "0755";
        "force user" = "smb";
        "force group" = "smb";
        "valid users" = "smb";
      };
      media = {
        path = /media/smb/media;
        "read only" = "yes";
        "guest ok" = "yes";
        "create mask" = "0640";
        "directory mask" = "0750";
        "force user" = "smb";
        "force group" = "smb";
        "write list" = "smb";
      };
    };
  };
  # to get this file start a smbd add users using 'smbpasswd -a <user>'
  # then export the database using 'pdbedit -e tdbsam:<location>'
  age.secrets.smbpassdb = {
    rekeyFile = ../../secrets/smbpassdb.tdb.age;
  };
  users.users.smb = {
    isSystemUser = true;
    group = "smb";
  };
  users.groups.smb = {};
  environment.persistence."/panzer/persist".directories = [
    {
      directory = "/media/smb/ggr-data";
      user = "smb";
      group = "smb";
      mode = "0750";
    }
    {
      directory = "/media/smb/patri-data";
      user = "smb";
      group = "smb";
      mode = "0750";
    }
    {
      directory = "/media/smb/media";
      user = "smb";
      group = "smb";
      mode = "0750";
    }
  ];
}
