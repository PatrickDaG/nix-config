{ config, pkgs, ... }:
{
  programs.niri.enable = true;
  hm.xdg.configFile."niri/config.kdl".text = config.lib.misc.mkPerHost {
    all = builtins.readFile ./niri.kdl;
    desktopnix = ''
      input {
          tablet {
              map-to-output "DP-3"
          }
      }
      output "DP-3" {
          mode "2560x1440@143.998"
          //scale 2.0
          position x=1920 y=540
          variable-refresh-rate on-demand=true
      }
      output "HDMI-A-1" {
          //mode "1920x1080@120.030"
          //scale 2.0
          position x=0 y=1080
      }
      output "DVI-D-1" {
          //mode "1920x1080@120.030"
          //scale 2.0
          position x=0 y=0
      }
      output "Unknown-1" {
          off
      }
      workspace "default" { open-on-output "DP-3" }
      workspace "mail" { open-on-output "DP-3" }
      workspace "games" { open-on-output "DP-3" }

      workspace "browser" { open-on-output "HDMI-A-1" }
      workspace "notes" { open-on-output "HDMI-A-1" }

      workspace "twitch" { open-on-output "DVI-D-1" }
      workspace "comms" { open-on-output "DVI-D-1" }

      spawn-at-startup "thunderbird"
    '';
    patricknix = '''';
  };
  hm.home.packages = [
    pkgs.xwayland-satellite
    pkgs.scripts.clone-term
  ];
}
