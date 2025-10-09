{ globals, ... }:
{
  networking.nftables.chains = {
    postrouting.to-forgejo = {
      after = [ "hook" ];
      rules = [
        "iifname wan ip daddr ${globals.wireguard.services-extern.hosts.elisabeth-forgejo.ipv4} tcp dport 22 masquerade random"
        "iifname wan ip6 daddr ${globals.wireguard.services-extern.hosts.elisabeth-forgejo.ipv6} tcp dport 22 masquerade random"
      ];
    };
    prerouting.to-forgejo = {
      after = [ "hook" ];
      rules = [
        "iifname wan tcp dport 9922 dnat ip to ${globals.wireguard.services-extern.hosts.elisabeth-forgejo.ipv4}:22"
        "iifname wan tcp dport 9922 dnat ip6 to ${globals.wireguard.services-extern.hosts.elisabeth-forgejo.ipv6}:22"
      ];
    };
  };
}
