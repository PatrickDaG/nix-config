{ globals, ... }:
{
  networking.nftables.chains = {
    postrouting.to-forgejo = {
      after = [ "hook" ];
      rules = [
        "iifname lan01 ip daddr ${globals.wireguard.services-extern.hosts.elisabeth-forgejo.ipv4} tcp dport 22 masquerade random"
        "iifname lan01 ip6 daddr ${globals.wireguard.services-extern.hosts.elisabeth-forgejo.ipv6} tcp dport 22 masquerade random"
      ];
    };
    prerouting.to-forgejo = {
      after = [ "hook" ];
      rules = [
        "iifname lan01 tcp dport 9922 dnat ip to ${globals.wireguard.services-extern.hosts.elisabeth-forgejo.ipv4}:22"
        "iifname lan01 tcp dport 9922 dnat ip6 to ${globals.wireguard.services-extern.hosts.elisabeth-forgejo.ipv6}:22"
      ];
    };
  };
}
