{
  config,
  pkgs,
  ...
}: {
  imports = [
    ./shells/zsh.nix
    #./shells/fish.nix
    ./programs/htop.nix
    ./shells/alias.nix
  ];
  home.stateVersion = "23.05";

  home.packages = with pkgs; [
    sqlite
    bat
  ];

  # has to be enabled to support zsh reverse search
  programs.fzf.enable = true;

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

  home.file.".ssh/1.pub".text = ''
    ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDZixkix0KfKuq7Q19whS5FQQg51/AJGB5BiNF/7h/LM cardno:15 489 049
  '';
  home.file.".ssh/2.pub".text = ''
    ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHxD4GOrwrBTG4/qQhm5hoSB2CP7W9g1LPWP11oLGOjQ cardno:23 010 997
  '';
  programs.ssh = {
    enable = true;
    matchBlocks = let
      identityFile = ["~/.ssh/1.pub" "~/.ssh/2.pub"];
    in {
      "elisabeth" = {
        hostname = "lel.lol";
        user = "root";
        inherit identityFile;
      };
      "patricknix" = {
        hostname = "localhost";
        user = "root";
        inherit identityFile;
      };

      "WSALVM" = {
        hostname = "172.10.8.156";
        user = "root";
        inherit identityFile;
      };

      "CompConst" = {
        hostname = "cp-service.kaist.ac.kr";
        user = "s20236085";
        port = 13001;
        inherit identityFile;
      };

      "valhalla" = {
        hostname = "valhalla.fs.tum.de";
        user = "grossmann";
        inherit identityFile;
      };
      "elisabethprivate" = {
        hostname = "lel.lol";
        user = "patrick";
        inherit identityFile;
      };
      "*.lel.lol" = {
        inherit identityFile;
      };
      "localhost" = {
        inherit identityFile;
      };
      "gitlab.lrz.de" = {
        inherit identityFile;
      };
      "*" = {
        identitiesOnly = true;
      };
    };
  };

  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;
    defaultEditor = true;
    withNodeJs = true;
    extraPackages = with pkgs; [
      # tabnine complition braucht unzip
      unzip
      # telescope fzf native braucht make
      gnumake
      # telescope braucht die
      ripgrep
      fd
    ];
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
