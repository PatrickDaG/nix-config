{pkgs, ...}: {
  home.packages = [pkgs.thunderbird];

  home.persistence."/state".directories = [".thunderbird"];
}
