{ lib, ... }:
{
  options.boot.initrd.luks.devices = lib.mkOption {
    type =
      with lib.types;
      attrsOf (submodule {
        config.crypttabExtraOpts = [
          "tpm2-device=auto"
          "tpm2-measure-pcr=yes"
        ];
      });
  };
}
