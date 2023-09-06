{nixosConfig, ...}: {
  home.smb = let
    address = "192.168.178.2";
    credentials = nixosConfig.age.secrets.smb-creds.path;
  in [
    {
      inherit address credentials;
      remotePath = "patri-data";
      automatic = true;
    }
    {
      inherit address credentials;
      remotePath = "ggr-data";
    }
    {
      inherit address credentials;
      remotePath = "patri-paperless";
      automatic = true;
    }
    {
      inherit address credentials;
      remotePath = "media";
      automatic = true;
    }
  ];
}
