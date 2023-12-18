inputs: _self: super: {
  lib =
    super.lib
    // {
      containers.mkConfig = name: attrs: config:
        super.lib.mkMerge [
          {
            config = {
              imports = [
                ../modules/services/nginx.nix
                ../modules/config
                ../modules/interface-naming.nix
              ];
              node.name = name;
              node.secretsDir = "${attrs.config.node.secretsDir}/guests/${name}";
              nixpkgs = {
                hostPlatform = attrs.config.nixpkgs.hostPlatform;
                overlays = attrs.pkgs.overlays;
                config = attrs.pkgs.config;
              };
              boot.initrd.systemd.enable = super.lib.mkForce false;
            };
            specialArgs = {
              inherit (attrs) lib inputs minimal stateVersion;
            };

            autoStart = true;
            macvlans = [
              "lan01:lan01-${name}"
            ];
            ephemeral = true;
            bindMounts = {
              "state" = {
                mountPoint = "/state";
                hostPath = "/state/containers/${name}";
                isReadOnly = false;
              };
              "persist" = {
                mountPoint = "/persist";
                hostPath = "/containers/${name}";
                isReadOnly = false;
              };
            };
            zfs.mountpoint = super.lib.mkDefault "/containers/${name}";
          }
          config
        ];
    };
}
