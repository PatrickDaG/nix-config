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
    ./common
  ];

  nixpkgs.config.allowUnfree = true;
  xsession.enable = true;
}
