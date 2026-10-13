MOD: TAGS: pkgs:
{
  # ${MOD} will be set to the main modifier key

  # General
  "${MOD}-q" = " close";

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
  "Alt-Tab" = "           cycle_all +1";
  "Alt-Shift-Tab" = "     cycle_all -1";

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
  "${MOD}-Shift-x" = "remove";
  "${MOD}-Shift-v" = "remove";
  "${MOD}-f" = "   floating toggle";
  "${MOD}-p" = "   pseudotile toggle";
  "${MOD}-space" = "   cycle_layout +1";
  "${MOD}-Shift-space" = "   cycle_layout -1";

  "${MOD}-t 	" = "spawn kitty";
  "${MOD}-b 	" = "pawn ${pkgs.firefox}/bin/firefox";
  "${MOD}-m 	" = "spawn ${pkgs.thunderbird}/bin/thunderbird";
  "Menu" = "spawn rofi -show drun";
}
// builtins.listToAttrs (
  map (x: {
    name = "${MOD}-${x}";
    value = "use_index ${x}";
  }) TAGS
)
// builtins.listToAttrs (
  map (x: {
    name = "${MOD}-Shift-${x}";
    value = "move_index ${x}";
  }) TAGS
)
