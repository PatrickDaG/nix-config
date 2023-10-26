{
  pkgs,
  lib,
  ...
}: {
  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;
    defaultEditor = true;
    withNodeJs = true;
    extraPackages = with pkgs; [
      # treesitter
      clang_15
      clang-tools_15
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
  home.persistence."/state".directories = [
    ".local/share/nvim"
    ".local/state/nvim"
    ".cache/nvim"
  ];
  home.shellAliases.nixvim = lib.getExe (pkgs.nixvim.makeNixvim {
    package = pkgs.neovim-unwrapped.overrideAttrs (_final: prev: {
      nativeBuildInputs = (prev.nativeBuildInputs or []) ++ [pkgs.makeWrapper];
      postInstall =
        (prev.postInstall or "")
        + ''
          wrapProgram $out/bin/nvim --add-flags "--clean"
        '';
    });
    colorscheme = "onedark";
    colorschemes.onedark.enable = true;
  });
}
