{config, ...}: {
  home.persistence."/persist/home/${config.home.username}" = {
    files = [
      ".ssh/know_hosts"
    ];
    directories = [
      "repos"
      "Downloads"
      ".local/share/atuin"

      # firefox muss halt
      ".mozilla"

      # nvim kinda nervig
      ".local/share/nvim/lazy"
      ".local/state/nvim"
      ".cache/nvim"

      ".local/share/direnv"
    ];
  };
}