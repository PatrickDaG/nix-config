{
  config,
  ...
}:
{
  boot.supportedFilesystems = [ "zfs" ];

  # The root pool should never be imported forcefully.
  # Failure to import is important to notice!
  boot.zfs.forceImportRoot = false;

  environment.systemPackages = [ config.boot.zfs.package ];

  # Might help with hangs mainly atuin
  #boot.kernelPatches = [
  #  {
  #    name = "enable RT_FULL";
  #    patch = null;
  #    extraConfig = ''
  #      PREEMPT y
  #      PREEMPT_BUILD y
  #      PREEMPT_VOLUNTARY n
  #      PREEMPT_COUNT y
  #      PREEMPTION y
  #  	DEBUG_INFO_BTF n
  #    '';
  #  }
  #];

  services.zfs = {
    autoScrub = {
      enable = true;
      interval = "weekly";
    };
    trim = {
      enable = true;
      interval = "weekly";
    };
  };
  # TODO remove once this is upstreamed
  boot.initrd.systemd.services."zfs-import-rpool".after = [ "cryptsetup.target" ];
}
