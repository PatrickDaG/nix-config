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
              ];
              node.name = name;
              node.secretsDir = attrs.config.node.secretsDir + "/guests/${name}";
              nixpkgs = {
                inherit (attrs.pkgs) overlays config;
                inherit (attrs.config.nixpkgs) hostPlatform;
              };
              boot.initrd.systemd.enable = super.lib.mkForce false;
            };
            specialArgs = {
              inherit (attrs) lib inputs minimal stateVersion;
            };
            extraFlags = [
              "--uuid=${builtins.substring 0 32 (builtins.hashString "sha256" name)}"
            ];

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
