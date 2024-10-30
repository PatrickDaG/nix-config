{
  # nu does not allow language access to completions
  # which makes it impossible to use custom completion menus
  # ZSH is still unbeatable with their completions
  programs.atuin.enableNushellIntegration = false;
  programs.nushell = {
    enable = true;
    configFile.source = ./config.nu;
    envFile.source = ./env.nu;
  };
  home.persistence."/state" = {
    directories = [ ".config/nushell" ];
  };
}
