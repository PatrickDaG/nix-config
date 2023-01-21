{
  config,
  pkgs,
  ...
}: {
  home = {
    stateVersion = "23.05";
    packages = with pkgs; [
      firefox
      thunderbird
      discord
    ];
  };
  imports = [
	common/kitty.nix
	common/herbstluftwm.nix
	common/desktop.nix
	./common ];
  nixpkgs.config.allowUnfree = true;
  xsession.enable = true;
  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;
    #withNodes = true;
  };
  programs.git.enable = true;

  programs.zsh.enable = true;

  xdg.configFile.nvim = {
    recursive = true;
    source = ../data/nvim;
  };
}
