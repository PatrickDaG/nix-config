_inputs: _self: super: {
  lib =
    super.lib
    // {
      containers.mkConfig = name: config:
        super.lib.mkMerge [
          {
            bindMounts = {
              "state" = {
                mountPoint = "/state";
                hostPath = "/state/containers/${name}";
              };
              "persist" = {
                mountPoint = "/persist";
                hostPath = "/containers/${name}";
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
