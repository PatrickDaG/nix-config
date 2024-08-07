{ lib, pkgs, ... }:
let
  # addon-path is base64 encode path
  cfgFile = lib.writeText ''
    <?xml version="1.0" encoding="UTF-8" standalone="no"?>
    <minion>
        <config-version>2</config-version>
        <client>
            <concurrent-updates>2</concurrent-updates>
            <game-scan-depth>4</game-scan-depth>
            <backup-dir>/home/patrick/.minion</backup-dir>
            <dark-theme/>
        </client>
        <user>
            <ga-user-id>d738b17b-2d14-4cb3-ab39-31ced61f7910</ga-user-id>
        </user>
        <game-configs never-ask-about-scanning="true">
            <game-config game-id="WOW" scannable="false"/>
            <game-config game-id="ESO" scannable="true"/>
        </game-configs>
        <drive-configs never-ask-about-scanning="true"/>
        <games>
            <game addon-path="L2hvbWUvcGF0cmljay8ubG9jYWwvc2hhcmUvU3RlYW1QYW56ZXIvc3RlYW1hcHBzL2NvbXBhdGRhdGEvMzA2MTMwL3BmeC9kcml2ZV9jL3VzZXJzL3N0ZWFtdXNlci9Eb2N1bWVudHMvRWxkZXIgU2Nyb2xscyBPbmxpbmUvbGl2ZS9BZGRPbnM=" auto-update="false" display-name="Elder Scrolls Online" game-id="ESO" unique-game-id="ESO-1"/>
        </games>
    </minion>
  '';
in
{
  home.packages = [ pkgs.minion ];
  # yet another program that uses the config file as a live state file
  # Why?
  home.activation.installMinionConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    run cp -f ${cfgFile} .minion/minion.xml
  '';
}
