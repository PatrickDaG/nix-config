{
  config,
  home-manager,
  ...
}: {
  home-manager.users.patrick.imports = [
    ./patrick.nix
    ./common
  ];

  home-manager.users.root = {
    imports = [./common];
  };
}
