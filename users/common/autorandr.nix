{
  config,
  pkgs,
  ...
}: {
  programs.autorandr = let
    dpi_hd = 96;
    dpi_uhd = 192;
    set_dpi = dpi: "echo 'Xft.dpi: ${toString dpi}' | ${pkgs.xorg.xrdb}/bin/xrdb -merge";
    eDP-1 = "00ffffffffffff0006afeb3000000000251b0104a5221378020925a5564f9b270c50540000000101010101010101010101010101010152d000a0f0703e803020350058c11000001852d000a0f07095843020350025a51000001800000000000000000000000000000000000000000002001430ff123caa8f0e29aa202020003e";
  in {
    enable = true;
    profiles.AStA = {
      fingerprint = {
        inherit eDP-1;
        # AStA linker arbeitsplatz linker Monitor
        DP-1-1 = "00ffffffffffff000472ed0688687101111e010380351e782aa135a35b4fa327115054b30c00714f818081c081009500b300d1c001012a4480a070382740082098040f282100001a023a801871382d40582c45000f282100001e000000fd00304b1e5512000a202020202020000000fc00423234375920430a202020202001cf020327f14b9002030411121300001f01230907078301000065030c001000681a00000101304be6023a801871382d40582c45000f282100001e8c0ad08a20e02d10103e96000f2821000018011d007251d01e206e2855000f282100001e8c0ad090204031200c4055000f282100001800000000000000000000000000000000d0";
        # AStA linker arbeitsplatz rechter Monitor
        DP-1-2 = "00ffffffffffff000472ed0682687101111e010380351e782aa135a35b4fa327115054b30c00714f818081c081009500b300d1c001012a4480a070382740082098040f282100001a023a801871382d40582c45000f282100001e000000fd00304b1e5512000a202020202020000000fc00423234375920430a202020202001d5020327f14b9002030411121300001f01230907078301000065030c001000681a00000101304be6023a801871382d40582c45000f282100001e8c0ad08a20e02d10103e96000f2821000018011d007251d01e206e2855000f282100001e8c0ad090204031200c4055000f282100001800000000000000000000000000000000d0";
      };
      config = {
        eDP-1 = {
          enable = true;
          primary = true;
          mode = "3840x2160";
          position = "0x0";
          gamma = "1";
        };
        DP-1-1 = {
          enable = true;
          mode = "1920x1080";
          position = "3840x0";
          rate = "60";
          gamma = "1";
        };
        DP-1-2 = {
          enable = true;
          mode = "1920x1080";
          position = "5760x0";
          rate = "60";
          gamma = "1";
        };
      };
      hooks.postswitch = set_dpi dpi_hd;
    };
    profiles.laptop = {
      fingerprint = {
        inherit eDP-1;
      };
      config = {
        eDP-1 = {
          enable = true;
          primary = true;
          mode = "3840x2160";
          position = "0x0";
          gamma = "1";
        };
      };
      hooks.postswitch = set_dpi dpi_uhd;
    };
    profiles.home = {
      fingerprint = {
        inherit eDP-1;
        # Acer Predator Main Monitor
        DP-1 = "00ffffffffffff00047290046bd08073261b0103803c227806ee91a3544c99260f505421080001010101010101010101010101010101565e00a0a0a029503020350056502100001a000000ff0023415350377974452f36413764000000fd001e9022de3b000a202020202020000000fc00584232373148550a202020202001750203204143030201230907018301000067030c001000007867d85dc40178c8005aa000a0a0a046503020350056502100001a6fc200a0a0a055503020350056502100001a6be600a0a0a0425030203a0056502100001e5a8700a0a0a03b503020350056502100001a1c2500a0a0a011503020350056502100001a00000000003c";
      };
      config = {
        eDP-1 = {
          enable = true;
          primary = true;
          mode = "3840x2160";
          position = "2560x0";
          gamma = "1";
        };
        DP-1 = {
          enable = true;
          mode = "2560x1440";
          position = "0x0";
          rate = "144";
          gamma = "1";
        };
      };
      hooks.postswitch = set_dpi dpi_hd;
    };
    profiles.TutoriumMI = {
      fingerprint = {
        inherit eDP-1;
        # Beamer 2.11.18
        DP-2 = "00ffffffffffff004ca30ba701010101081a0103800000780ade50a3544c99260f5054a10800814081c0950081809040b300a9400101283c80a070b023403020360040846300001a9e20009051201f304880360040846300001c000000fd0017550f5c11000a202020202020000000fc004550534f4e20504a0a202020200115020328f151901f202205140413030212110706161501230907078301000066030c00300080e200fb023a801871382d40582c450040846300001e011d801871382d40582c450040846300001e662156aa51001e30468f330040846300001e302a40c8608464301850130040846300001e00000000000000000000000000000070";
      };
      config = {
        eDP-1 = {
          enable = true;
          primary = true;
          mode = "3840x2160";
          position = "0x0";
          gamma = "1";
        };
        DP-2 = {
          enable = true;
          mode = "1920x1080";
          position = "0x0";
          rate = "144";
          gamma = "1";
        };
      };
      hooks.postswitch = set_dpi dpi_uhd;
    };
  };
}