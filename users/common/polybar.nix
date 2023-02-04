{
	config,
	...
}:
let
  color = {
	bground = ;
	fground = ;
in
{
	services.polybar = {
		enable = true;
		settings = {
			"bar/main" = {
				monitor = "DP-1";
				monitro.fallback = "eDP-1";
				bottom = true;

				dpi = 96;
				heigh = 22;

				background = color.bground;
				foreground = color.fground;

				font = {
					0 = "FiraCode Nerd Font Mono:style=Medium:size=13";
					1 = "";
					2 = "Iosevka Nerd Font:style=Medium:size=16";
					3 = "Font Awesome 5 Pro:style=Solid:size=13";
					4 = "Font Awesome 5 Pro:style=Regular:size=13";
					5 = "Font Awesome 5 Pro:style=Light:size=13";
				};

				modules = {
					left = [ "icon" "left1" "title" "left2" ];
					center = [ "workspaces" ];
					right = [ "right5" "alsa" "right4" "battery" "right3" "network" "date" "right1" "keyboardswitcher" ];
				};

				tray = {
					position = "right";
					background = color.shade1;
				};

				enable.ipc = true;


			};
	};
}
