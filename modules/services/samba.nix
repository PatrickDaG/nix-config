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
        log level = 1
            hosts allow = 192.168.178. 127.0.0.1 10.0.0. localhost
         hosts deny = 0.0.0.0/0
         guest account = nobody
         map to guest = bad user
      passdb backend = tdbsam:/tmp/smbpasswd.tdb
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
  age.secrets.smbpasswd.rekeyFile = ../../secrets/smbpasswd.age;
  system.activationScripts.importSMBPasswd = {
    text = ''
      ${config.services.samba.package}/bin/pdbedit -i smbpasswd:${config.age.secrets.smbpasswd.path} -e tdbsam:/tmp/smbpasswd.tdb
    '';
  };
  users.users.smb = {
    isSystemUser = true;
    group = "smb";
    hashedPassword = config.secrets.secrets.global.users.smb.passwordHash;
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
