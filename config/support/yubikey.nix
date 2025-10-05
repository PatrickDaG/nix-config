{ pkgs, lib, ... }:
let
  yubikey-to-serial = {
    "23010997" = {
      age-key = ../../keys/PatA.pub;
      gpg-uid = pkgs.writeText "gpg-uid" "D00D847207456602C24209C453E76B2F373CCD13";
    };
    "15489049" = {
      age-key = ../../keys/PatC.pub;
      gpg-uid = pkgs.writeText "gpg-uid" "26031A25A16D8CF791F8AD34451F95EFB8BECD0F";
    };
  };
  on-yubikey = pkgs.writeShellScript "on-yubikey-event" ''
    SERIAL_FILE="/run/yubikey/serial"

    # Get the action from environment variable (passed by udev)
    ACTION="$1"

    # Different behavior based on action
    case "$ACTION" in
      add)
        serial="$(${lib.getExe pkgs.yubikey-manager} list --serials | head -n1 | tr -d '[:space:]')"
        rm "/run/yubikey/*"
        echo "$serial" > $SERIAL_FILE
        chmod 644 "$SERIAL_FILE"
        case "$serial" in
          ${lib.concatMapAttrsStringSep "\n" (name: value: ''
              "${name}")
            ${lib.concatMapAttrsStringSep "\n" (name: value: ''
              ln -s ${value} /run/yubikey/${name}
            '') value}
            ;;
          '') yubikey-to-serial}
          *)
            ;;
        esac
        ;;
      remove)
        rm "/run/yubikey/*"
        ;;
      *)
        echo "$(date): Unknown action: $ACTION" >> /var/log/yubikey-events.log
        ;;
    esac
  '';
in
{
  environment.systemPackages = with pkgs; [
    yubikey-personalization
    yubikey-manager
    age-plugin-yubikey
  ];

  services.pcscd.enable = true;

  services.udev.packages = with pkgs; [
    yubikey-personalization
    libu2f-host
  ];

  services.udev.extraRules = ''
    # YubiKey detection - triggers on connect and disconnect
    # Yubico vendor ID is 1050
    ACTION=="add|remove", SUBSYSTEM=="usb", ATTRS{idVendor}=="1050", RUN+="${on-yubikey} $env{ACTION}"
  '';

  systemd.tmpfiles.rules = [
    "d /run/yubikey 0755 root root -"
  ];
}
