{
  pkgs,
  lib,
  ...
}:
with lib; let
  cfg = config.programs.touchegg;

  # common options
  fingers = mkOption {
    type = types.ints.between 2 5;
    description = ''
      amount of simoultaneous fingers
      needed to trigger the gesture
    '';
    default = 3;
    example = "";
  };

  # Submodules for the different gestures
  swipe_gesture = types.submodule {
    inherit fingers;

    direction = mkOption {
      type = types.enum ["UP" "DOWN" "LEFT" "RIGHT"];
      description = ''
        the swipe direction
      '';
      example = "UP";
    };
  };

  pinch_gesture = types.submodule {
    inherit fingers;

    direction = mkOption {
      type = types.enum ["IN" "OUT"];
      description = ''
        the pinch direction
      '';
      example = "IN";
    };
  };

  tap_gesture = types.submodule {
    inherit fingers;
  };

  # common options
  animate = mkOption {
    type = tyes.bool;
    description = ''
      Whether to display the animation
    '';
    default = false;
  };

  color = mkOption {
    type = type.str;
    description = ''
      hex value of the animation color
    '';
    default = "3E9FED";
    example = "909090";
  };

  borderColor = mkOption {
    type = type.str;
    description = ''
      hex value of the color of the
      animation border
    '';
    default = "3E9FED";
    example = "FF90FF";
  };

  animation_common_options = {
    inherit animate color borderColor;
  };

  # Submodules for the actions performed
  # by gestures
  maximize_restore_window = {
    inherit animation_common_options;
  };

  minimize_restore_window = {
  };

  tile_window = {
    inherit animation_common_options;
    direction = mkOption {
      type = types.enum ["left" "right"];
      description = ''
        Which side of the screen to snap to
      '';
      default = "";
      example = "left";
    };
  };

  fullscreen_window = {
    inherit animation_common_options;
  };

  close_window = {
    inherit animation_common_options;
  };

  change_desktop = {
    inherit animation_common_options;

    direction = mkOption {
      type = types.enum [
        "previous"
        "next"
        "up"
        "down"
        "left"
        "right"
        "auto"
      ];
      description = ''
        The desktop/workspace to switch to. It is recommended to use previous/next for better compatibility. However, some desktop environments, like KDE, allow to configure a grid of desktops and up/down/left/right come in handy. With SWIPE gestures, auto will use your natural scroll preferences to figure out the direction.
      '';
      default = "auto";
      example = "next";
    };

    cyclic = mkOption {
      type = types.bool;
      description = ''
        Set it to true when using
        previous/next directions
        to navigate from last
        desktop to first desktop
        or from first to last.
      '';
      default = true;
      example = false;
    };

    animationPosition = mkOption {
      type = types.enum ["up" "down" "left" "right" "auto"];
      description = ''
        Edge of the screen where the animation will be displayed. With SWIPE gestures, auto will use your natural scroll preferences to figure out the animation position.
      '';
      default = "auto";
      example = "up";
    };
  };

  show_desktop = {
    inherit animation_common_options;
  };

  repeat = mkOption {
    type = types.bool;
    description = ''
      Whether to execute the keyboard shortcut multiple times (default: false). This is useful to perform actions like pinch to zoom.
    '';
    default = false;
    example = true;
  };

  on = mkOption {
    type = types.enum ["begin" "end"];
    description = ''
      Only used when repeat is false. Whether to execute the shortcut at the beginning or at the end of the gesture.
    '';
    example = "begin";
    default = "end";
  };

  times = mkOption {
    type = types.ints.between 2 15;
    description = ''
      Only used when repeat is true. Number of times to repeat the action.
    '';
    example = 5;
  };

  animation = mkOption {
    type = types.nullOr (types.enum [
      "CHANGE_DESKTOP_UP"
      "CHANGE_DESKTOP_DOWN"
      "CHANGE_DESKTOP_LEFT"
      "CHANGE_DESKTOP_RIGHT"
      "CLOSE_WINDOW"
      "MAXIMIZE_WINDOW"
      "RESTORE_WINDOW"
      "MINIMIZE_WINDOW"
      "SHOW_DESKTOP"
      "EXIST_SHOW_DESKTOP"
      "TILE_WINDOW_LEFT"
      "TILE_WINDOW_RIGHT"
    ]); # TODO
    description = ''
      Which animation to use
    '';
    default = "";
    example = "TILE_WINDOW_RIGHT";
  };

  send_keys = {
    inherit animation_common_options;
    inherit repeat on times animation;

    modifiers = mkOption {
      type = types.str;
      description = ''
        Typical values are: Shift_L, Control_L, Alt_L, Alt_R, Meta_L, Super_L, Hyper_L. You can use multiple keysyms: Control_L+Alt_L. See X11 keysymdefs
      '';
      default = "";
      example = "Shift_L";
    };

    keys = mkOption {
      type = types.str;
      description = ''
        Shortcut keys. You can use multiple keysyms: A+B+C. See X11 keysymdefs.
      '';
      example = "A+c";
    };

    decreaseKeys = mkOption {
      type = types.str;
      description = ''
        Only used when repeat is true. Keys to press when you change the gesture direction to the opposite. You can use multiple keysyms: A+B+C. This is useful to perform actions like pinch to zoom.
      '';
      example = "Y+Z";
    };
  };

  run_command = {
    inherit animation_common_options;
    inherit repeat on times animation;

    command = mkOption {
      type = types.str;
      description = ''
        The command to execute
      '';
      default = "";
      example = "ls -lah";
    };

    decreaseCommand = mkOption {
      type = types.str;
      description = ''
        Only used when repeat is true. Keys to press when you change the gesture direction to the opposite. You can use multiple keysyms: A+B+C. This is useful to perform actions like pinch to zoom.
      '';
      example = "Y+Z";
    };
  };

  mouse_click = {
    button = mkOption {
      type = types.enum ["left" "right" "middle"];
      description = ''
        Which button to press
      '';
      example = "left";
    };

    on = mkOption {
      type = types.enum ["begin" "end"];
      description = ''
        If the command should be executed on the beginning or on the end of the gesture.
      '';
      default = "end";
      example = "begin";
    };
  };

  gestureModule = let
    helpStr = ''
      The gesture to trigger.
      Only one of 'swipe_gesture' 'pinch_gesture' and 'tap_gesture'
      can be defined
    '';
  in
    types.submodule {
      options = {
        # hopefully this works it not
        # because of submodule weirdness

        swipe_gesture = mkOption {
          type = types.listOf swipe_gesture;
          description = helpStr;
          default = [];
        };

        pinch_gesture = mkOption {
          type = types.listOf pinch_gesture;
          description = helpStr;
          default = [];
        };

        tap_gesture = mkOption {
          type = types.listOf tap_gesture;
          description = helpStr;
          default = [];
        };

        description = ''
          the type of gesture
        '';

        example = ""; # TODO
      };

      action = mkOption {
        type =
          types.oneOf [
          ];
        description = ''
          The actions to perform
        '';
      };
    };
in {
  options.programs.touchegg = {
    enable = mkEnableOption "Touch gesture daemon";

    animation_delay = mkOption {
      type = types.ints.unsigned;
      description = ''
        Delay, in milliseconds,
        since the gesture starts
        before the animation is displayed
      '';
      default = 150;
      example = "";
    };

    action_execute_threshold = mkOption {
      type = types.ints.between 0 100;
      description = ''
        Percentage of the
        gesture to be completed
        to apply the action.
        Set to 0 to execute
        actions unconditionally
      '';
      default = 20;
      example = "";
    };

    color = mkOption {
      type = types.str;
      description = ''
        Color of the animation
      '';
      default = "39E9FED";
      example = "";
    };

    borderColor = mkOption {
      type = types.str;
      description = ''
        Color of the animation
      '';
      default = "9E9FED";
      example = "";
    };

    gestures = mkOption {
      type = types.attrOf gestureModule;
      description = "touchegg gestures";
      default = {};
    };
  };

  config = mkIf cfg.enable {
    #assertions =
    # TODO
    home.packages = [pkgs.touchegg];

    xdg.configFile.touchegg = {
      target = "touchegg/touchegg.conf";
      text = builtins.toXML {};
    };

    #systemd.user.services.touchegg =
  };
}
