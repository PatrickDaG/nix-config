MOD: TAGS:
{
  # ${MOD} will be set to the main modifier key

  # General
  "${MOD}-q" = " close";
  #"${MOD}-Shift-Escape"  = " spawn ${HOME}/.config/rofi/powermenu/powermenu.sh";

  # Moving
  "${MOD}-Shift-Left" = " shift left";
  "${MOD}-Shift-Down" = " shift down";
  "${MOD}-Shift-Up" = " shift up";
  "${MOD}-Shift-Right" = " shift right";

  "${MOD}-Shift-n" = " shift left";
  "${MOD}-Shift-r" = " shift down";
  "${MOD}-Shift-l" = " shift up";
  "${MOD}-Shift-s" = " shift right";

  # Resizing
  "${MOD}-Control-Left" = " resize left +$RESIZE_STEP";
  "${MOD}-Control-Down" = " resize down +$RESIZE_STEP";
  "${MOD}-Control-Up" = " resize up +$RESIZE_STEP";
  "${MOD}-Control-Right" = " resize right +$RESIZE_STEP";

  "${MOD}-Control-n" = " resize left +$RESIZE_STEP";
  "${MOD}-Control-r" = " resize down +$RESIZE_STEP";
  "${MOD}-Control-l" = " resize up +$RESIZE_STEP";
  "${MOD}-Control-s" = " resize right +$RESIZE_STEP";

  "${MOD}-Shift-Control-Left" = "  resize right -$RESIZE_STEP";
  "${MOD}-Shift-Control-Down" = "  resize up -$RESIZE_STEP";
  "${MOD}-Shift-Control-Up" = "  resize down -$RESIZE_STEP";
  "${MOD}-Shift-Control-Right" = "  resize left -$RESIZE_STEP";

  "${MOD}-Shift-Control-s" = " resize right -$RESIZE_STEP";
  "${MOD}-Shift-Control-l" = " resize up -$RESIZE_STEP";
  "${MOD}-Shift-Control-r" = " resize down -$RESIZE_STEP";
  "${MOD}-Shift-Control-n" = " resize left -$RESIZE_STEP";

  # Focusing
  "${MOD}-Left" = " focus left";
  "${MOD}-Down" = " focus down";
  "${MOD}-Up" = " focus up";
  "${MOD}-Right" = " focus right";
  # Focusing
  "${MOD}-n" = "  focus left";
  "${MOD}-r" = "  focus down";
  "${MOD}-l" = "    focus up";
  "${MOD}-s" = " focus right";

  "${MOD}-BackSpace" = "   cycle_monitor";
  "${MOD}-c" = "   cycle";
  "${MOD}-i" = "   jumpto urgent";
  "${MOD}-Tab" = "   cycle_all +1";
  "${MOD}-Shift-Tab" = "   cycle_all -1";

  # Tag cycle
  "${MOD}-period" = "  use_index +1 ";
  "${MOD}-comma" = "  use_index -1 ";

  # Splitting frames
  "${MOD}-x" = " split bottom";
  "${MOD}-v" = " split right";
  "${MOD}-Control-space" = " split explode";

  # Layouting
  "${MOD}-Return" = "   fullscreen toggle";
  "${MOD}-shift-x" = "         remove";
  "${MOD}-f" = "   floating toggle";
  "${MOD}-p" = "   pseudotile toggle";
  "${MOD}-space" = "   cycle_layout +1";
  "${MOD}-Shift-space" = "   cycle_layout -1";

  "${MOD}-t 	" = "spawn kitty";
  "${MOD}-b 	" = "spawn firefox";
  "${MOD}-m 	" = "spawn thunderbird";
  "${MOD}-Shift-l 	" = "spawn systemctl suspend";
  "${MOD}-Shift-f 	" = "spawn /home/patrick/scripts/fix_shit.sh";
}
// builtins.listToAttrs (map (x: {
    name = "${MOD}-${x}";
    value = "use_index ${x}";
  })
  TAGS)
// builtins.listToAttrs (map (x: {
    name = "${MOD}-Shift-${x}";
    value = "move_index ${x}";
  })
  TAGS)
