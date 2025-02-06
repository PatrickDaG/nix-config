{
  globals = {
    modules = [
      ../modules/globals.nix
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
