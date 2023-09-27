{
  config,
  nixosConfig,
  lib,
  pkgs,
  ...
}:
# shared sway/i3 config
let
  modifier = "Mod4";
  down = "r";
  left = "n";
  right = "s";
  up = "l";
  terminal = "kitty";
  cfg = {
    inherit modifier terminal;
    focus = {
      followMouse = false;
      mouseWarping = false;
    };
    #bindkeysToCode = true;
    window.titlebar = false;
    floating.titlebar = false;
    workspaceLayout = "stacking";
    bars = map (x: x // config.lib.stylix.i3.bar) [
      {
        mode = "dock";
        workspaceButtons = true;
        workspaceNumbers = false;
        statusCommand = "${config.programs.i3status-rust.package}/bin/i3status-rs config-main.toml";
        trayOutput = "primary";
      }
    ];

    workspaceOutputAssign = let
      output = out:
        lib.lists.imap1 (i: x: {
          workspace = "${toString i}:${x}";
          output = out;
        });
    in
      {
        "desktopnix" =
          output "HDMI-0" ["1" "2" "3" "4"]
          ++ output "DP-4" ["j" "d" "u" "a"]
          ++ output "DVI-D-0" ["F1" "F2" "F3" "F4"];
        "patricknix" =
          output "eDP-1" ["1" "2" "3" "4"]
          ++ output "DP-1" ["j" "d" "u" "a"];
      }
      .${nixosConfig.node.name}
      or {};

    keybindings =
      (lib.attrsets.mergeAttrsList (map (x: (let
          key = lib.elemAt (lib.strings.splitString ":" x.workspace) 1;
        in {
          "${modifier}+${key}" = "workspace ${x.workspace}";
          "${modifier}+Shift+${key}" = "move container to workspace ${x.workspace}";
        }))
        cfg.workspaceOutputAssign))
      // {
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
      };
  };
in {
  wayland.windowManager.sway.config = cfg;
  xsession.windowManager.i3.config = cfg;

  programs.i3status-rust = {
    enable = true;
    bars.main = {
      blocks = [
        {
          block = "net";
        }
        {
          block = "cpu";
        }
        {
          block = "nvidia_gpu";
        }
        {
          block = "sound";
        }
        {
          block = "backlight";
          missing_format = "";
        }
        {
          block = "time";
          format = "$icon  $timestamp.datetime(f:'%a %d.%m.%y %H:%M:%S') ";
          interval = 1;
        }
      ];
      theme = "native";
      icons = "material-nf";
      settings."icons.overrides" = {
        cpu = "";
      };
    };
  };
}
