{
  imports = [
    # port 80
    ./freshrss.nix
    ./firefly.nix
    # port 3000
    ./yourspotify.nix
    # porte 3002
    ./mealie.nix
    # port 3003
    ./linkwarden.nix
    # Port 3004
    ./atuin.nix
  ];
}
