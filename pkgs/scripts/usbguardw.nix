{ writeShellApplication }:
writeShellApplication {
  name = "usguardw";
  text = ''
    set -euo pipefail
    printenv
  '';
}
