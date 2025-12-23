{
  imports = [
    # port 80
    ./freshrss.nix
    ./firefly.nix
    ./bookstack.nix
    # port 3000
    ./yourspotify.nix
    # port 3001
    ./invidious.nix
    # port 3003
    ./linkwarden.nix
    # porte 3002
    ./mealie.nix
  ];
}
