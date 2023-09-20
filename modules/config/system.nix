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
    generatedSecretsDir = config.node.secretsDir + "/generated/";
  };
  security.sudo.enable = false;
  security.tpm2 = {
    enable = true;
    pkcs11.enable = true;
  };
  # Just before switching, remove the agenix directory if it exists.
  # This can happen when a secret is used in the initrd because it will
  # then be copied to the initramfs under the same path. This materializes
  # /run/agenix as a directory which will cause issues when the actual system tries
  # to create a link called /run/agenix. Agenix should probably fail in this case,
  # but doesn't and instead puts the generation link into the existing directory.
  # TODO See https://github.com/ryantm/agenix/pull/187.
  system.activationScripts.removeAgenixLink.text = "[[ ! -L /run/agenix ]] && [[ -d /run/agenix ]] && rm -rf /run/agenix";
  system.activationScripts.agenixNewGeneration.deps = ["removeAgenixLink"];

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
