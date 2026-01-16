{ pkgs, ... }:
{
  users.users.build = {
    isSystemUser = true;
    shell = pkgs.bash;
    group = "nogroup";
    extraGroups = [ "nix-build" ];
    createHome = false;
  };
  users.groups.nix-build = { };
}
