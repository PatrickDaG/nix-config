{config, ...}: let
  address = [
    "10.0.0.2/32"
  ];
  peer = {
    endpoint = "lel.lol:51820";
    publicKey = "t/jR2/0hxBXG0Ytah2w5RQ1gn94k0/Ku9LYcbRR7pXo=";
    presharedKeyFile = config.rekey.secrets.wireguard-pre.path;
  };
  privateKeyFile = config.rekey.secrets.wireguard-priv.path;
in {
  rekey.secrets = {
    wireguard-pre.file = ../../secrets/wireguard/elisabeth-pre.wg.age;
    wireguard-priv.file = ../../secrets/wireguard/elisabeth-priv.wg.age;
  };

  networking.wg-quick.interfaces = {
    wg-intern = {
      inherit address privateKeyFile;
      peers = [
        (peer
          // {
            allowedIPs = [
              "10.0.0.1/32"
            ];
          })
      ];
    };
    wg-all = {
      inherit address privateKeyFile;
      peers = [
        (peer
          // {
            allowedIPs = [
              "0.0.0.0/0"
              "::/0"
            ];
          })
      ];
      autostart = false;
    };
  };
}
