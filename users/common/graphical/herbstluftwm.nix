{
  config,
  pkgs,
  lib,
  ...
}: let
  # set the modifier key to WIN
  MOD = "Super";
  #set the default resize step for herbstluft
  RESIZE_STEP = 0.05;
  TAGS = map toString (lib.lists.range 1 9);
  data_dir = ../../../data/herbstluftwm;
in {
  home.file.".xinitrc".source = data_dir + /xinitrc;
  xsession.windowManager.herbstluftwm = {
    enable = true;
    package = pkgs.herbstluftwm.overrideAttrs (finalAttrs: previousAttrs: {
      doCheck = false;
    });
    extraConfig = ''
      herbstclient set auto_detect_monitors 1
      killall polybar
      polybar &

      herbstclient attr theme.tiling.reset 1
      herbstclient attr theme.floating.reset 1
      herbstclient attr theme.active.color "#9fbc00"
      herbstclient attr theme.normal.color "#454545"
      herbstclient attr theme.urgent.color orange
      herbstclient attr theme.inner_width 1
      herbstclient attr theme.inner_color black
      herbstclient attr theme.border_width 3
      herbstclient attr theme.floating.border_width 4
      herbstclient attr theme.floating.outer_width 1
      herbstclient attr theme.floating.outer_color black
      herbstclient attr theme.active.inner_color "#3E4A00"
      herbstclient attr theme.active.outer_color "#3E4A00"
      herbstclient attr theme.background_color "#141414"
    '';

    tags = TAGS;

    mousebinds = {
      "${MOD}-Button1" = "move";
      "${MOD}-Button2" = "zoom";
      "${MOD}-Button3" = "resize";
    };

    keybinds = import (data_dir + /keybinds.nix) MOD TAGS pkgs;
    settings = {
      "default_frame_layout" = 3;

      "frame_border_active_color" = "#222222";
      "frame_border_normal_color" = "#101010";
      "frame_bg_normal_color" = "#565656";
      "frame_bg_active_color" = "#345F0C";
      "frame_border_width" = 1;
      "always_show_frame" = 1;
      "frame_bg_transparent" = 1;
      "frame_transparent_width" = 5;
      "frame_gap" = 4;

      "window_gap" = 0;
      "frame_padding" = 0;
      "smart_window_surroundings" = 0;
      "smart_frame_surroundings" = 1;
      "mouse_recenter_gap" = 0;

      "tree_style" = "╾│ ├└╼─┐";
    };
    rules = [
      # Focus new clients by default
      "focus=on"

      # Focus dialogs
      "windowtype='_NET_WM_WINDOW_TYPE_DIALOG' focus=on"

      # Do not manage windows of type NOTIFICATION, DOCK, DESKTOP
      "windowtype~'_NET_WM_WINDOW_TYPE_(NOTIFICATION|DOCK|DESKTOP)' manage=off"

      # Use pseudotiles for windows of type DIALOG, UTILITY, SPLASH
      "windowtype~'_NET_WM_WINDOW_TYPE_(DIALOG|UTILITY|SPLASH)' pseudotile=on"
    ];
  };
}
