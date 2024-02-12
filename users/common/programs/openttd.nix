{pkgs, ...}: {
  home.persistence."/persist".directories = [
    ".local/share/openttd"
  ];

  home.packages = [
    pkgs.openttd
  ];
}
