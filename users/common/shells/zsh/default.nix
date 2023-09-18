{
  pkgs,
  config,
  ...
}: {
  imports = [
    ../starfish.nix
  ];

  # for zsh-histdb
  # TODO replace sqlite inplace with nix path
  home.packages = [pkgs.sqlite];

  # save history in xdg data home
  home.sessionVariables.HISTDB_FILE = "${config.xdg.dataHome}/zsh/history.db";

  # has to be enabled to support zsh reverse search
  programs.fzf.enable = true;

  programs.carapace = {
    enable = true;
    # this would source all completers sadly some are worse than the builtin completers
    enableZshIntegration = false;
  };

  programs.nix-index.enable = true;
  programs.nix-index-database.comma.enable = true;

  programs.zsh = {
    enable = true;
    dotDir = ".config/zsh";
    history = {
      extended = true;
      path = "${config.xdg.dataHome}/zsh/zsh_history";
      save = 1000000;
      share = false;
    };
    initExtra = builtins.readFile ./zshrc;
    # This needs to be loaded befor zsh-fast-syntax-highlighting
    # is sourced as that overwrites all widgets to redraw with highlighting
    initExtraFirst = ''
      if autoload history-search-end; then
      	zle -N history-beginning-search-backward-end history-search-end
      	zle -N history-beginning-search-forward-end  history-search-end
      fi

    '';
    plugins = [
      {
        name = "fzf-tab";
        src = "${pkgs.zsh-fzf-tab}/share/fzf-tab";
      }
      {
        name = "fast-syntax-highlighting";
        src = "${pkgs.zsh-fast-syntax-highlighting}/share/zsh/site-functions";
      }
      {
        # TODO change to separate packages
        name = "zsh-histdb";
        src = pkgs.zsh-histdb;
      }
      {
        name = "zsh-histdb-skim";
        src = pkgs.zsh-histdb-skim;
      }
    ];
  };
  home.persistence."/state".directories = [
    ".local/share/zsh"
  ];
}
