{ pkgs, ... }:
{
  stylix.targets.fuzzel.enable = true;
  home.packages = with pkgs; [
    (writeShellScriptBin "fuzzel" ''
      ${fuzzel}/bin/fuzzel --background-color=000000ff
    '')
  ];
}
