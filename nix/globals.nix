{
  globals = {
    optModules = [
      ../modules/globals.nix
    ];
    defModules = [
      ../globals.nix
    ];
    attrkeys = [
      "accounts"
      "hosts"
      "domains"
      "services"
      "hetzner"
      "net"
      "users"
      "monitoring"
    ];
  };
}
