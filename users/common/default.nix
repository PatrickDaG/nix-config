{
  config,
  pkgs,
  ...
}: {
  programs.fzf.enable = true;

  home.packages = with pkgs; [
    sqlite
    bat
    ripgrep
  ];

  programs.gpg = {
    enable = true;
    scdaemonSettings.disable-ccid = true;
    publicKeys = [
      {
        source = ../../data/pubkey.gpg;
        trust = 5;
      }
      {
        source = ../../data/newpubkey.gpg;
        trust = 5;
      }
    ];
  };
  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;
    defaultEditor = true;
    withNodeJs = true;
  };

  xdg.configFile.nvim = {
    recursive = true;
    source = ../../data/nvim;
  };
  programs.git.enable = true;
  services.gpg-agent = {
    enable = true;
    enableSshSupport = true;
  };

  programs.git.signing = {
    key = null;
    signByDefault = true;
  };

  programs.zsh = {
    enable = true;
    initExtra = builtins.readFile ../../data/zshrc;
    plugins = [
      {
        name = "powerlevel10k";
        file = "share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
        src = pkgs.zsh-powerlevel10k;
      }
      {
        name = "fzf-tab";
        file = "share/fzf-tab/fzf-tab.plugin.zsh";
        src = pkgs.zsh-fzf-tab;
      }
      {
        name = "fast-syntax-highlighting";
        file = "share/zsh/site-functions/fast-syntax-highlighting.plugin.zsh";
        src = pkgs.zsh-fast-syntax-highlighting;
      }
      {
        name = "zsh-histdb";
        file = "sqlite-history.zsh";
        src = pkgs.fetchFromGitHub {
          owner = "larkery";
          repo = "zsh-histdb";
          rev = "30797f0";
          sha256 = "PQIFF8kz+baqmZWiSr+wc4EleZ/KD8Y+lxW2NT35/bg=";
        };
      }
      #{	name = "zsh-histdb-skim";
      #	file = "zsh-histdb-skim.zsh";
      #	src = pkgs.fetchFromGitHub {
      #		owner = "m42e";
      #		repo = "zsh-histdb-skim";
      #		rev = "v0.8.1";
      #		sha256 = "pcXSGjOKhN2nrRErggb8JAjw/3/bvTy1rvFhClta1Vs=";
      #	};
      #}
    ];
  };
}
