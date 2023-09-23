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
  floating.titlebar = false;
  workspaceLayout = "stacking";
  workspaceOutputAssign = [
    {
      workspace = "1";
      output = "DP-4";
    }
    {
      workspace = "2";
      output = "DP-4";
    }
    {
      workspace = "3";
      output = "DP-4";
    }
    {
      workspace = "4";
      output = "DP-4";
    }

    {
      workspace = "F1";
      output = "HDMI-0";
    }
    {
      workspace = "F2";
      output = "HDMI-0";
    }
    {
      workspace = "F3";
      output = "HDMI-0";
    }
    {
      workspace = "F4";
      output = "HDMI-0";
    }

    {
      workspace = "Q";
      output = "DVI-D-0";
    }
    {
      workspace = "W";
      output = "DVI-D-0";
    }
    {
      workspace = "E";
      output = "DVI-D-0";
    }
    {
      workspace = "R";
      output = "DVI-D-0";
    }
  ];
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

    "${modifier}+v" = "splith";
    "${modifier}+udiaeresis" = "splitv";
    "${modifier}+Return" = "fullscreen toggle";

    "${modifier}+odiaeresis" = "layout stacking";
    "${modifier}+y" = "layout tabbed";
    "${modifier}+z" = "layout toggle split";

    "${modifier}+f" = "floating toggle";
    "${modifier}+space" = "focus mode_toggle";

    "${modifier}+comma" = "workspace prev_on_output";
    "${modifier}+period" = "workspace next_on_output";

    "${modifier}+1" = "workspace number 1";
    "${modifier}+2" = "workspace number 2";
    "${modifier}+3" = "workspace number 3";
    "${modifier}+4" = "workspace number 4";

    "${modifier}+F1" = "workspace F1";
    "${modifier}+F2" = "workspace F2";
    "${modifier}+F3" = "workspace F3";
    "${modifier}+F4" = "workspace F4";

    "${modifier}+j" = "workspace Q";
    "${modifier}+d" = "workspace W";
    "${modifier}+u" = "workspace E";
    "${modifier}+a" = "workspace R";

    "${modifier}+Shift+1" = "move container to workspace number 1";
    "${modifier}+Shift+2" = "move container to workspace number 2";
    "${modifier}+Shift+3" = "move container to workspace number 3";
    "${modifier}+Shift+4" = "move container to workspace number 4";

    "${modifier}+Shift+F1" = "move container to workspace F1";
    "${modifier}+Shift+F2" = "move container to workspace F2";
    "${modifier}+Shift+F3" = "move container to workspace F3";
    "${modifier}+Shift+F4" = "move container to workspace F4";

    "${modifier}+Shift+J" = "move container to workspace Q";
    "${modifier}+Shift+D" = "move container to workspace W";
    "${modifier}+Shift+u" = "move container to workspace E";
    "${modifier}+Shift+a" = "move container to workspace R";
  };
}
