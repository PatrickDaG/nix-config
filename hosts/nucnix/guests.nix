{
  config,
  inputs,
  lib,
  minimal,
  ...
}:
{
  guests = lib.genAttrs [ "homeassistant" "esphome" "nginx" ] (guestName: {
    backend = "container";
    autostart = true;
    # Siblings of the host's lan-house macvlan can reach its WireGuard endpoint.
    container.macvlans = [ "lan01:mv-house" ];
    zfs = {
      "/state" = {
        pool = "rpool";
        dataset = "local/guests/${guestName}";
      };
      "/persist" = {
        pool = "rpool";
        dataset = "safe/guests/${guestName}";
      };
    };
    extraSpecialArgs = {
      inherit (inputs.self) nodes globals;
      inherit (inputs.self.pkgs.x86_64-linux) lib;
      inherit inputs minimal;
    };
    modules = [
      ../../config/basic
      ./${guestName}.nix
      inputs.microvm.nixosModules.microvm-options
      {
        node.secretsDir = config.node.secretsDir + "/${guestName}";
        networking.nftables.firewall.zones.untrusted.interfaces = [ "mv-house" ];
        systemd.network.networks."10-mv-house" = lib.mkIf (guestName == "nginx") {
          DHCP = lib.mkForce "no";
          address = [
            "192.168.178.6/24"
            "fd7a:3539:5f0e:0::6/64"
          ];
          gateway = [
            "192.168.178.1"
            "fd7a:3539:5f0e:0::1"
          ];
        };
      }
    ];
  });

  # Match this dongle by serial so other USB serial devices cannot replace it.
  services.udev.extraRules = ''
    SUBSYSTEM=="tty", ATTRS{idVendor}=="10c4", ATTRS{idProduct}=="ea60", ATTRS{serial}=="d86f998a81f3ef119046bf1b6d9880ab", SYMLINK+="zigbee", GROUP="dialout", MODE="0660", TAG+="systemd", ENV{SYSTEMD_ALIAS}+="/dev/zigbee"
  '';

  containers.homeassistant = {
    extraFlags = [ "--bind=/dev/zigbee:/dev/zigbee" ];
    allowedDevices = [
      {
        modifier = "rw";
        node = "/dev/zigbee";
      }
    ];
  };

  # Wait for udev before nspawn resolves the device bind mount and allowlist.
  systemd.services."container@homeassistant" = {
    requires = [ "dev-zigbee.device" ];
    after = [ "dev-zigbee.device" ];
  };
}
