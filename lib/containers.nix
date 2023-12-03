_inputs: _self: super: {
  lib =
    super.lib
    // {
      containers.mkConfig = name: config:
        super.lib.mkMerge [
          {
            bindmounts = {
              "state" = {
                mountpoint = "/state";
                hostPath = "/state/containers/${name}";
              };
              "persist" = {
                mountpoint = "/persist";
                hostPath = config.zfs.mountpoint;
              };
            };
            #config = {...}: {
            #};
          }
          config
        ];
    };
}
