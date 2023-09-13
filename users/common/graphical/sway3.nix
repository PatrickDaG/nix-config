# shared sway/i3 config
let
  modifier = "Mod4";
  down = "r";
  left = "n";
  right = "s";
  up = "l";
  terminal = "kitty";
in {
  inherit modifier terminal;
  focus = {
    followMouse = false;
    mouseWarping = false;
  };
  #bindkeysToCode = true;
  window.titlebar = false;
  keybindings = {
    "${modifier}+t" = "exec ${terminal}";
    "${modifier}+b" = "exec firefox";
    "${modifier}+m" = "exec thunderbird";
    "${modifier}+q" = "kill";

    "${modifier}+${left}" = "focus left";
    "${modifier}+${down}" = "focus down";
    "${modifier}+${up}" = "focus up";
    "${modifier}+${right}" = "focus right";

    "${modifier}+Left" = "focus left";
    "${modifier}+Down" = "focus down";
    "${modifier}+Up" = "focus up";
    "${modifier}+Right" = "focus right";

    "${modifier}+Shift+${left}" = "move left";
    "${modifier}+Shift+${down}" = "move down";
    "${modifier}+Shift+${up}" = "move up";
    "${modifier}+Shift+${right}" = "move right";

    "${modifier}+Shift+Left" = "move left";
    "${modifier}+Shift+Down" = "move down";
    "${modifier}+Shift+Up" = "move up";
    "${modifier}+Shift+Right" = "move right";

    "${modifier}+x" = "splith";
    "${modifier}+v" = "splitv";
    "${modifier}+Return" = "fullscreen toggle";

    "${modifier}+j" = "layout stacking";
    "${modifier}+d" = "layout tabbed";
    "${modifier}+u" = "layout toggle split";

    "${modifier}+f" = "floating toggle";
    "${modifier}+space" = "focus mode_toggle";

    "${modifier}+Comma" = "workspace prev";
    "${modifier}+Period" = "workspace next";

    "${modifier}+1" = "workspace number 1";
    "${modifier}+2" = "workspace number 2";
    "${modifier}+3" = "workspace number 3";
    "${modifier}+4" = "workspace number 4";
    "${modifier}+5" = "workspace number 5";
    "${modifier}+6" = "workspace number 6";
    "${modifier}+7" = "workspace number 7";
    "${modifier}+8" = "workspace number 8";
    "${modifier}+9" = "workspace number 9";

    "${modifier}+Shift+1" = "move container to workspace number 1";
    "${modifier}+Shift+2" = "move container to workspace number 2";
    "${modifier}+Shift+3" = "move container to workspace number 3";
    "${modifier}+Shift+4" = "move container to workspace number 4";
    "${modifier}+Shift+5" = "move container to workspace number 5";
    "${modifier}+Shift+6" = "move container to workspace number 6";
    "${modifier}+Shift+7" = "move container to workspace number 7";
    "${modifier}+Shift+8" = "move container to workspace number 8";
    "${modifier}+Shift+9" = "move container to workspace number 9";
  };
}
