inputs: _self: super: {
  lib =
    super.lib
    // {
      containers.mkConfig = name: config:
        super.lib.mkMerge [
          {
            config = {
              imports = [
                ../modules/config/impermanence
                ../modules/config/net.nix
                ../modules/interface-naming.nix

                inputs.impermanence.nixosModules.impermanence
              ];
            };

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
            #config = {...}: {
            #};
          }
          config
        ];
    };
}
