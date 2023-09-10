{
  inputs,
  lib,
  pkgs,
  config,
  ...
}: {
  age.rekey = {
    inherit
      (inputs.self.secretsConfig)
      masterIdentities
      extraEncryptionPubkeys
      ;

    forceRekeyOnSystem = builtins.extraBuiltins.unsafeCurrentSystem;
    hostPubkey = let
      pubkeyPath = config.node.secretsDir + "/host.pub";
    in
      lib.mkIf (lib.pathExists pubkeyPath || lib.trace "Missing pubkey for ${config.node.name}: ${toString pubkeyPath} not found, using dummy replacement key for now." false)
      pubkeyPath;
  };
  security.sudo.enable = false;

  time.timeZone = lib.mkDefault "Europe/Berlin";
  i18n.defaultLocale = "C.UTF-8";
  services.xserver = {
    layout = "de";
    xkbVariant = "bone";
  };
  console = {
    font = "ter-v28n";
    packages = with pkgs; [terminus_font];
    useXkbConfig = true; # use xkbOptions in tty.
    keyMap = lib.mkDefault "de-latin1-nodeadkeys";
  };

  users.mutableUsers = false;
  environment.systemPackages = with pkgs; [
    wget
    gcc
    tree
    rage
    file
    ripgrep
    killall
    fd
  ];

  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";

  secrets.secretFiles = let
    local = config.node.secretsDir + "/secrets.nix.age";
  in
    {
      global = ../../secrets/secrets.nix.age;
    }
    // lib.optionalAttrs (config.node.name != null && lib.pathExists local) {inherit local;};
}
