{
  config,
  pkgs,
  lib,
  ...
}:
with lib; let
  #
  # GESTURES
  #
  # each on has a member type as a single entry enum
  # to be able to definitely distinguish them
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
    type = mkOption {
      type = types.enum ["swipe"];
      description = ''
        Type of gesture to perform
      '';
      default = "";
    };

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
    type = mkOption {
      type = types.enum ["pinch"];
      description = ''
        Type of gesture to perform
      '';
      default = "";
    };

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
    type = mkOption {
      type = types.enum ["tap"];
      description = ''
        Type of gesture to perform
      '';
      default = "";
    };
  };

  #
  # ACTIONS
  #

  # common options
  animate = mkOption {
    type = tyes.bool;
    description = ''
      Whether to display the animation
    '';
    default = false;
  };

  color = mkOption {
    type = types.str;
    description = ''
      hex value of the animation color
    '';
    default = "3E9FED";
    example = "909090";
  };

  borderColor = mkOption {
    type = types.str;
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
              The desktop/workspace to switch to.
        It is recommended to use previous/next for better compatibility.
        However, some desktop environments, like KDE,
        allow to configure a grid of desktops and up/down/left/right come in handy.
        With SWIPE gestures, auto will use your natural scroll preferences to figure out the direction.
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
    inherit on;
    button = mkOption {
      type = types.enum ["left" "right" "middle"];
      description = ''
        Which button to press
      '';
      example = "left";
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
      gestures = mkOption {
        # hopefully this works it not
        # because of submodule weirdness
        type = types.enum [swipe_gesture pinch_gesture tap_gesture];
        description = helpStr;
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

      application = mkOption {
        type = types.string;
        description = ''
          The name of the application
          in which this gestures should trigger
        '';
        default = "ALL";
        example = "Google-chrome,Chromium-browser";
      };
    };
in {
  options.programs.touchegg = {
    inherit color borderColor;
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

    gestures = mkOption {
      type = types.attrsOf gestureModule;
      description = "touchegg gestures";
      default = {};
    };
  };

  config = let
    cfg = config.programs.touchegg;
  in
    mkIf cfg.enable {
      # TODO
      home.packages = [pkgs.touchegg];

      xdg.configFile.touchegg = {
        target = "touchegg/touchegg.conf";
        text = ''
          <touchégg>

          	<settings>
          		<!--
          		Delay, in milliseconds, since the gesture starts before the animation is displayed.
          		Default: 150ms if this property is not set.
          		Example: Use the MAXIMIZE_RESTORE_WINDOW action. You will notice that no animation is
          		displayed if you complete the action quick enough. This property configures that time.
          		-->
          		<property name="animation_delay">${cfg.animation_delay}</property>

          		<!--
          		Percentage of the gesture to be completed to apply the action. Set to 0 to execute actions unconditionally.
          		Default: 20% if this property is not set.
          		Example: Use the MAXIMIZE_RESTORE_WINDOW action. You will notice that, even if the
          		animation is displayed, the action is not executed if you did not move your fingers far
          		enough. This property configures the percentage of the gesture that must be reached to
          		execute the action.
          		-->
          		<property name="action_execute_threshold">${cfg.action_execute_threshold}</property>

          		<!--
          		Global animation colors can be configured to match your system colors using HEX notation:

          			<color>909090</color>
          			<borderColor>FFFFFF</borderColor>

          		You can also use auto:

          			<property name="color">auto</property>
          			<property name="borderColor">auto</property>

          		Notice that you can override an specific animation color.
          		-->
          		<property name="color">${cfg.color}</property>
          		<property name="borderColor">${cfg.borderColor}</property>
          	</settings>

          	<!--
          		Configuration for every application.
          	-->
          	<application name="All">
          		<gesture type="SWIPE" fingers="3" direction="UP">
          		<action type="MAXIMIZE_RESTORE_WINDOW">
          			<animate>true</animate>
          		</action>
          		</gesture>

          		<gesture type="SWIPE" fingers="3" direction="DOWN">
          		<action type="MINIMIZE_WINDOW">
          			<animate>true</animate>
          		</action>
          		</gesture>

          		<gesture type="SWIPE" fingers="3" direction="LEFT">
          		<action type="TILE_WINDOW">
          			<direction>left</direction>
          			<animate>true</animate>
          		</action>
          		</gesture>

          		<gesture type="SWIPE" fingers="3" direction="RIGHT">
          		<action type="TILE_WINDOW">
          			<direction>right</direction>
          			<animate>true</animate>
          		</action>
          		</gesture>

          		<gesture type="PINCH" fingers="3" direction="IN">
          		<action type="CLOSE_WINDOW">
          			<animate>true</animate>
          			<color>F84A53</color>
          			<borderColor>F84A53</borderColor>
          		</action>
          		</gesture>

          		<gesture type="SWIPE" fingers="4" direction="UP">
          		<action type="CHANGE_DESKTOP">
          			<direction>auto</direction>
          			<animate>true</animate>
          			<animationPosition>auto</animationPosition>
          		</action>
          		</gesture>

          		<gesture type="SWIPE" fingers="4" direction="DOWN">
          		<action type="CHANGE_DESKTOP">
          			<direction>auto</direction>
          			<animate>true</animate>
          			<animationPosition>auto</animationPosition>
          		</action>
          		</gesture>

          		<gesture type="SWIPE" fingers="4" direction="RIGHT">
          		<action type="SEND_KEYS">
          			<repeat>false</repeat>
          			<modifiers>Super_L</modifiers>
          			<keys>S</keys>
          			<on>begin</on>
          		</action>
          		</gesture>

          		<gesture type="PINCH" fingers="4" direction="OUT">
          		<action type="SHOW_DESKTOP">
          			<animate>true</animate>
          		</action>
          		</gesture>

          		<gesture type="PINCH" fingers="4" direction="IN">
          		<action type="SEND_KEYS">
          			<repeat>false</repeat>
          			<modifiers>Super_L</modifiers>
          			<keys>A</keys>
          			<on>begin</on>
          		</action>
          		</gesture>

          		<gesture type="TAP" fingers="2">
          		<action type="MOUSE_CLICK">
          			<button>3</button>
          			<on>begin</on>
          		</action>
          		</gesture>

          		<gesture type="TAP" fingers="3">
          		<action type="MOUSE_CLICK">
          			<button>2</button>
          			<on>begin</on>
          		</action>
          		</gesture>
          	</application>

          	<!--
          		Configuration for specific applications.
          	-->

          	<application name="Google-chrome,Chromium-browser">
          		<gesture type="PINCH" fingers="2" direction="IN">
          		<action type="SEND_KEYS">
          			<repeat>true</repeat>
          			<modifiers>Control_L</modifiers>
          			<keys>KP_Subtract</keys>
          			<decreaseKeys>KP_Add</decreaseKeys>
          		</action>
          		</gesture>

          		<gesture type="PINCH" fingers="2" direction="OUT">
          		<action type="SEND_KEYS">
          			<repeat>true</repeat>
          			<modifiers>Control_L</modifiers>
          			<keys>KP_Add</keys>
          			<decreaseKeys>KP_Subtract</decreaseKeys>
          		</action>
          		</gesture>
          	</application>

          	</touchégg>

        '';
      };
    };
}
