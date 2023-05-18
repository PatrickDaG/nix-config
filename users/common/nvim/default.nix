{pkgs, ...}: {
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
    source = ./.;
  };
}
