MOD: TAGS: pkgs:
''
         general {
         	gaps_in = 1
         	gaps_out = 0
  		no_cursor_warps = true
         }

         input {
         	sensitivity = 0
         	kb_layout = de,de
         	kb_variant = bone,
         	repeat_rate = 60
         	repeat_delay = 235
         	# Only change focus on mouse click
         	follow_mouse = 2
  		float_switch_override_focus = 0
      	accel_profile = flat
      touchpad {
       	natural_scroll = true
       }
         }

      gestures {
      	workspace_swipe = true
      	workspace_swipe_numbered = true
      }

      misc {
     disable_hyprland_logo = true
  mouse_move_focuses_monitor = false
      }

   binds {
  	focus_preferred_method = 1
   }

         # keybinds
         bind=${MOD},q,killactive,
         bind=${MOD},return,fullscreen,
         bind=${MOD},f,togglefloating
         bind=${MOD},tab,cyclenext,
         bind=ALT,tab,cyclenext,
         bind=,Menu,exec,rofi -show drun

         bind=${MOD},left,movefocus,l
         bind=${MOD},right,movefocus,r
         bind=${MOD},up,movefocus,u
         bind=${MOD},down,movefocus,d

         bind=${MOD},n,movefocus,l
         bind=${MOD},s,movefocus,r
         bind=${MOD},l,movefocus,u
         bind=${MOD},r,movefocus,d

         bind=${MOD} + SHIFT,left,movewindow,l
         bind=${MOD} + SHIFT,right,movewindow,r
         bind=${MOD} + SHIFT,up,movewindow,u
         bind=${MOD} + SHIFT,down,movewindow,d

   bindm=${MOD},mouse:272,movewindow

         bind=${MOD} + SHIFT,n,movewindow,l
         bind=${MOD} + SHIFT,s,movewindow,r
         bind=${MOD} + SHIFT,l,movewindow,u
         bind=${MOD} + SHIFT,r,movewindow,d

         bind=${MOD},comma,workspace,-1
         bind=${MOD},period,workspace,+1




         bind=${MOD},b,exec,firefox
         bind=${MOD},t,exec,kitty
         bind=${MOD} + SHIFT,l,exec,systemctl suspend -i
         bind=${MOD} + SHIFT,Escape,exit
   #fix xwayland hidpi
   exec-once = ${pkgs.xorg.xprop}/bin/xprop -root -f _XWAYLAND_GLOBAL_OUTPUT_SCALE 32c -set _XWAYLAND_GLOBAL_OUTPUT_SCALE 2
   env = GDK_SCALE,2
   env = XCURSOR_SIZE,48

      workspace = eDP-1, 42

      exec-once=bash -c "waybar >/tmp/waybar_error.log"
''
+ builtins.concatStringsSep "\n" (map (
    x: ''
      bind=${MOD},${x.fst},workspace,${x.snd}
      bind=${MOD} + SHIFT,${x.fst},movetoworkspace,${x.snd}
      bind=${MOD} + CTRL + SHIFT,${x.fst},movetoworkspacesilent,${x.snd}
    ''
  )
  (pkgs.lib.lists.zipLists (map toString (pkgs.lib.lists.range 1 9)) TAGS))