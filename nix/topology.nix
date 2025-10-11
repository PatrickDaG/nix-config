{ config, ... }:
let
  inherit (config.lib.topology)
    mkInternet
    mkRouter
    mkConnection
    mkSwitch
    mkDevice
    ;
in
{
  networks = {
    home = {
      name = "Heimnetz";
      cidrv4 = "192.168.178.0/24";
    };
  };
  nodes = {
    internet = mkInternet {
      connections = [
        (mkConnection "fritzbox" "wan1")
        (mkConnection "mailnix" "lan01")
      ];
    };
    fritzbox = mkRouter "FritzBox" {
      info = "FRITZ!Box 7520";
      interfaceGroups = [
        [
          "wan1"
        ]
        [
          "eth1"
          "eth2"
          "eth3"
        ]
      ];
      interfaces.eth1 = {
        addresses = [ "192.168.178.1" ];
        network = "home";
      };
      connections.eth1 = mkConnection "switch-ganzoben" "eth1";
    };
    switch-ganzoben = mkSwitch "Switch Ganzoben" {
      info = "TPLink 16 Port";
      interfaceGroups = [
        [
          "eth1"
          "eth2"
          "eth3"
          "eth4"
          "eth5"
          "eth6"
          "eth7"
          "eth8"
          "eth9"
          "eth10"
          "eth11"
          "eth12"
          "eth13"
          "eth14"
          "eth15"
          "eth16"
        ]
      ];
      connections = {
        eth2 = mkConnection "switch-waschkueche" "eth1";
        eth3 = mkConnection "switch-patrick" "eth5";
        eth4 = mkConnection "docking-station-ganzoben" "lan";
        eth5 = mkConnection "desktop-ganzoben" "lan";
        eth6 = mkConnection "nucnix" "lan01";
        eth9 = mkConnection "drucker" "lan";
        eth10 = mkConnection "homematic" "lan";
        eth11 = mkConnection "raspberry-pi" "lan";
        eth12 = mkConnection "fernseher" "lan";
        eth16 = mkConnection "devolo" "lan";
      };
    };
    switch-waschkueche = mkSwitch "Switch Waschküche" {
      info = "TPLink 8 Port";
      interfaceGroups = [
        [
          "eth1"
          "eth2"
          "eth3"
          "eth4"
          "eth5"
          "eth6"
          "eth7"
          "eth8"
        ]
      ];
      connections = {
        eth2 = mkConnection "switch-server" "eth1";
        eth3 = mkConnection "desktop-david" "lan";
        eth7 = mkConnection "solar-anlage" "lan";
        eth8 = mkConnection "solar-anlage" "lan";
      };
    };
    switch-server = mkSwitch "Switch Server" {
      info = "TPLink 5 Port";
      interfaceGroups = [
        [
          "eth1"
          "eth2"
          "eth3"
          "eth4"
          "eth5"
        ]
      ];
      connections = {
        eth2 = mkConnection "elisabeth" "lan01";
        eth3 = mkConnection "homematic-ip" "lan";
        eth4 = mkConnection "dect" "lan";
        eth5 = mkConnection "docking-station-keller" "lan";
      };
    };
    switch-patrick = mkSwitch "Switch Patrick" {
      info = "5 Port";
      interfaceGroups = [
        [
          "eth1"
          "eth2"
          "eth3"
          "eth4"
          "eth5"
        ]
      ];
      connections = {
        eth4 = mkConnection "desktopnix" "lan01";
        eth3 = mkConnection "patricknix" "lan01";
      };
    };
    docking-station-ganzoben = mkDevice "Docking Station Ganzoben" {
      info = "Docking Station";
      interfaces.lan = { };
    };
    desktop-ganzoben = mkDevice "Desktop Ganzoben" {
      info = "Desktop";
      interfaces.lan = { };
    };
    drucker = mkDevice "Drucker" {
      info = "HP Drucker";
      interfaces.lan = { };
    };
    homematic = mkDevice "homematic" {
      info = "Homematic zentrale";
      interfaces.lan = { };
    };
    raspberry-pi = mkDevice "RaspberryPi" {
      info = "Raspberry-Pi 5";
      interfaces.lan = { };
    };
    fernseher = mkDevice "fernseher" {
      info = "LG? Fernseher";
      interfaces.lan = { };
    };
    devolo = mkDevice "devolo" {
      info = "devolo";
      interfaces.lan = { };
    };
    solar-anlage = mkDevice "solar" {
      info = "solar anlage+batterie";
      interfaces.lan = { };
    };
    desktop-david = mkDevice "desktop-david" {
      info = "Desktop";
      interfaces.lan = { };
    };
    homematic-ip = mkDevice "homematic-ip" {
      info = "homematic-ip point";
      interfaces.lan = { };
    };
    dect = mkDevice "dect" {
      info = "Teflon";
      interfaces.lan = { };
    };
    docking-station-keller = mkDevice "Docking-station Keller" {
      info = "Für die kellerarbeiter";
      interfaces.lan = { };
    };
  };
}
