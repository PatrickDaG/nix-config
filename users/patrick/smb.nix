{ config, nodes, ... }:
{
  hm.home.smb =
    let
      address = nodes.elisabeth-samba.config.wireguard.samba-patrick.ipv4;
      credentials = config.age.secrets.smb-creds.path;
    in
    [
      {
        inherit address credentials;
        remotePath = "patri";
        automatic = true;
      }
      {
        inherit address credentials;
        remotePath = "patri-important";
        automatic = true;
      }
      {
        inherit address credentials;
        remotePath = "patri-paperless";
        automatic = true;
      }
      {
        inherit address credentials;
        remotePath = "family-data";
        automatic = true;
      }
      {
        inherit address credentials;
        remotePath = "printer";
        automatic = true;
      }
      {
        inherit address credentials;
        remotePath = "media";
        automatic = true;
      }
    ];
  age.secrets = {
    smb-creds = {
      owner = "patrick";
      rekeyFile = ../../secrets/smb.cred.age;
    };
  };
}
