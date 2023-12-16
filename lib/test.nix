{
  config,
  pkgs,
  ...
}: {
  networking.hostName = "lololo";
  programs.fuse.userAllowOther = true;
  environment.systemPackages = [pkgs.hello];
}
