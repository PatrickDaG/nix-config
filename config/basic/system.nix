{
  inputs,
  lib,
  pkgs,
  config,
  ...
}:
{
  system.stateVersion = "24.05";

  age.rekey = {
    inherit (inputs.self.secretsConfig) masterIdentities extraEncryptionPubkeys;

    storageMode = "derivation";

    forceRekeyOnSystem = builtins.extraBuiltins.unsafeCurrentSystem;
    hostPubkey =
      let
        pubkeyPath = config.node.secretsDir + "/host.pub";
      in
      lib.mkIf (
        lib.pathExists pubkeyPath
        || lib.trace "Missing pubkey for ${config.node.name}: ${toString pubkeyPath} not found, using dummy replacement key for now." false
      ) pubkeyPath;
    generatedSecretsDir = config.node.secretsDir + "/generated/";
    cacheDir = "/var/tmp/agenix-rekey/\"$UID\"";
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
  system.activationScripts = lib.mkIf (config.age.secrets != { }) {
    removeAgenixLink.text = "[[ ! -L /run/agenix ]] && [[ -d /run/agenix ]] && rm -rf /run/agenix";
    agenixNewGeneration.deps = [ "removeAgenixLink" ];
  };

  time.timeZone = lib.mkDefault "Europe/Berlin";
  i18n.defaultLocale = "C.UTF-8";
  console = {
    font = "${pkgs.terminus_font}/share/consolefonts/ter-v28n.psf.gz";
    packages = with pkgs; [ terminus_font ];
    useXkbConfig = true; # use xkbOptions in tty.
    keyMap = lib.mkDefault "de-latin1-nodeadkeys";
  };

  environment.systemPackages = with pkgs; [
    wget
    tree
    rage
    file
    dua
    ripgrep
    killall
    fd
    kitty.terminfo
    nvd
    unzip
    bat
    # fix pcscd
    pcscliteWithPolkit.out
    wireguard-tools
  ];

  environment.ldso32 = null;

  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
}
