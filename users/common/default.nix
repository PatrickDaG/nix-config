{
  config,
  pkgs,
  ...
}: {
	imports = [
		./zsh.nix
		];

  home.packages = with pkgs; [
    sqlite
    bat
    ripgrep
	killall
	fzf
  ];

  programs.gpg = {
    enable = true;
	settings = import ../../data/gpg/gpg.conf.nix;
    scdaemonSettings.disable-ccid = true;
    publicKeys = [
      {
        source = ../../data/gpg/pubkey.gpg;
        trust = 5;
      }
      {
        source = ../../data/gpg/newpubkey.gpg;
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

  programs.git = {
	aliases = {
		cs = "commit -v -S";
		s = "status";
		a = "add";
		p = "push";
	};
	extraConfig.init.defaultBranch = "main";
	extraConfig.pull.ff = "only";
	signing = {
		key = null;
		signByDefault = true;
	};
  };

}
