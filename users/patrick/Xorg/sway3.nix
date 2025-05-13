{
  config,
  lib,
  pkgs,
  ...
}:
let
  nconfig = config;
in
# shared sway/i3 config
{
  hm =
    { config, ... }:
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
        window.titlebar = false;
        floating.titlebar = false;
        workspaceLayout = "stacking";
        workspaceAutoBackAndForth = true;
        startup = lib.mkAfter [
          { command = "swaymsg focus output DP-3 && swaysmg workspace 1:j"; }
          { command = "swaymsg focus output DVI-D-1 && swaysmg workspace 1:F1"; }
          { command = "swaymsg focus output HDMI-A-1 && swaysmg workspace 1:F3"; }
        ];
        floating.criteria = [
          { class = "Pavucontrol"; }
          { class = "streamlink-twitch-gui"; }
          { title = "Extension: (Bitwarden Password Manager)"; }
        ];

        assigns = {
          "2:d" = [ { class = "^firefox$"; } ];
          "2:F4" = [ { class = "^spotify$"; } ];
          "3:u" = [ { class = "^thunderbird$"; } ];
          "4:a" = [
            { class = "^bottles$"; }
            { class = "^steam$"; }
            { class = "^prismlauncher$"; }
          ];
          "1:F1" = [
            { class = "^discord$"; }
            { title = "WebCord"; }
            { class = "^TeamSpeak 3$"; }
          ];
          "2:F2" = [
            { class = "^Signal$"; }
            { class = "^TelegramDesktop$"; }
          ];
        };

        workspaceOutputAssign =
          let
            output =
              out:
              lib.lists.imap1 (
                i: x: {
                  workspace = "${toString i}:${x}";
                  output = out;
                }
              );
          in
          nconfig.lib.misc.mkPerHost {
            "desktopnix" =
              output "DP-3" [
                "j"
                "d"
                "u"
                "a"
                "x"
              ]
              ++ output "DVI-D-1" [
                "F1"
                "F2"
              ]
              ++ output "HDMI-A-1" [
                "F3"
                "F4"
              ];
            "patricknix" = output "eDP-1" [
              "j"
              "d"
              "u"
              "a"
              "x"
            ];
          };

        keybindings =
          (lib.attrsets.mergeAttrsList (
            map (
              x:
              (
                let
                  key = lib.elemAt (lib.strings.splitString ":" x.workspace) 1;
                in
                {
                  "${modifier}+${key}" = "workspace ${x.workspace}";
                  "${modifier}+Shift+${key}" = "move container to workspace ${x.workspace}";
                }
              )
            ) config.xsession.windowManager.i3.config.workspaceOutputAssign
          ))
          // {
            "${modifier}+t" = "exec ${terminal}";
            "${modifier}+b" = "exec firefox";
            "${modifier}+m" = "exec thunderbird";
            "${modifier}+q" = "kill";
            "${modifier}+c" = "exec ${lib.getExe pkgs.scripts.clone-term}";
            "XF86AudioPlay" = "exec ${pkgs.playerctl}/bin/playerctl play-pause";
            "XF86AudioPrev" = "exec ${pkgs.playerctl}/bin/playerctl next";
            "XF86AudioNext" = "exec ${pkgs.playerctl}/bin/playerctl previous";
            "XF86AudioMute" = "exec ${pkgs.pamixer}/bin/pamixer -t";
            "XF86AudioLowerVolume" = "exec ${pkgs.pamixer}/bin/pamixer -d 5";
            "XF86AudioRaiseVolume" = "exec ${pkgs.pamixer}/bin/pamixer -i 5";

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
    in
    {
      wayland.windowManager.sway.config = cfg;
      xsession.windowManager.i3.config = cfg;
    };
}
