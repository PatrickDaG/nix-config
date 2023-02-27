pkgs:
# This is small script to map touchinputs to outputs
# in an ideal world this would happen automatically but
# with udev and X11 we truly do not live in an ideal world
"${pkgs.writeShellScriptBin "fix-shit" ''
     xinput --map-to-output "ELAN2514:00 04F3:2817" eDP-1
     xinput --map-to-output "ELAN2514:00 04F3:2817 Stylus Pen (0)" eDP-1
  xset r rate 235 60
  autorandr -c
''}/bin/fix-shit"
