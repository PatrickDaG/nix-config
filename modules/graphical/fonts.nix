{pkgs, ...}: {
  fonts = {
    enableGhostscriptFonts = false;
    fontDir.enable = false;
    fontconfig = {
      localConf = ''
        <?xml version="1.0"?>
        <!DOCTYPE fontconfig SYSTEM "fonts.dtd">
        <fontconfig>
            <alias binding="weak">
                <family>monospace</family>
                <prefer>
                    <family>emoji</family>
                </prefer>
            </alias>
            <alias binding="weak">
                <family>sans-serif</family>
                <prefer>
                    <family>emoji</family>
                </prefer>
            </alias>
            <alias binding="weak">
                <family>serif</family>
                <prefer>
                    <family>emoji</family>
                </prefer>
            </alias>
        </fontconfig>
      '';
    };
    packages = with pkgs; [
      (nerdfonts.override {fonts = ["FiraCode"];})
      ibm-plex
      dejavu_fonts
      unifont
      freefont_ttf
      gyre-fonts # TrueType substitutes for standard PostScript fonts
      liberation_ttf
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-cjk-serif
      noto-fonts-emoji
      noto-fonts-extra
    ];
  };
  stylix.fonts = {
    serif = {
      package = pkgs.dejavu_fonts;
      name = "IBM Plex Serif";
    };

    sansSerif = {
      package = pkgs.dejavu_fonts;
      name = "IBM Plex Sans";
    };

    monospace = {
      # No need for patched nerd fonts, kitty can pick up on them automatically,
      # and ideally every program should do that: https://sw.kovidgoyal.net/kitty/faq/#kitty-is-not-able-to-use-my-favorite-font
      package = pkgs.jetbrains-mono;
      name = "JetBrains Mono";
    };

    emoji = {
      package = pkgs.noto-fonts-emoji;
      name = "Noto Color Emoji";
    };
  };
}
