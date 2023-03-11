MOD: TAGS: pkgs:
''
  general {
  	gaps_in = 1
  	gaps_out = 0
  }

  input {
  	sensitivity = -0.8
  	kb_model = pc105
  	kb_layout = de
  	kb_variant = bone
  	repeat_rate = 60
  	repeat_delay = 235
  	# Only change focus on mouse click
  	follow_mouse = 2
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

  bind=${MOD} + Shift,left,movewindow,l
  bind=${MOD} + Shift,right,movewindow,r
  bind=${MOD} + Shift,up,movewindow,u
  bind=${MOD} + Shift,down,movewindow,d

  bind=${MOD} + Shift,n,movewindow,l
  bind=${MOD} + Shift,s,movewindow,r
  bind=${MOD} + Shift,l,movewindow,u
  bind=${MOD} + Shift,r,movewindow,d




  bind=${MOD},b,exec,firefox
  bind=${MOD},t,exec,kitty
  bind=${MOD} + Shift,Escape,exit
''
+ builtins.concatStringsSep "\n" (map (
    x: ''
      bind=${MOD},${x},workspace,${x}
      bind=${MOD} + Shift,${x},movetoworkspace,${x}
    ''
  )
  TAGS)
