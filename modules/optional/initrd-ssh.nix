{
  config,
  pkgs,
  ...
}: {
  age.secrets.initrd_host_ed25519_key.generator.script = "ssh-ed25519";

  boot.initrd.network.enable = true;
  boot.initrd.network.ssh = {
    enable = true;
    port = 4;
    # I think this is impure as the new initrd gets generated before
    # agenix decrypts your secrets, meaning your initrd hostkey
    # need two activations to change as well as that to enable this
    # module you need to set hostKeys to a dummy value and generate
    # and invalid initrd once
    hostKeys = [config.age.secrets.initrd_host_ed25519_key.path];
  };

  # Make sure that there is always a valid initrd hostkey available that can be installed into
  # the initrd. When bootstrapping a system (or re-installing), agenix cannot succeed in decrypting
  # whatever is given, since the correct hostkey doesn't even exist yet. We still require
  # a valid hostkey to be available so that the initrd can be generated successfully.
  # The correct initrd host-key will be installed with the next update after the host is booted
  # for the first time, and the secrets were rekeyed for the the new host identity.
  system.activationScripts.agenixEnsureInitrdHostkey = {
    text = ''
      if [[ ! -e ${config.age.secrets.initrd_host_ed25519_key.path} ]]; then
        mkdir -p "$(dirname "${config.age.secrets.initrd_host_ed25519_key.path}")"
        ${pkgs.openssh}/bin/ssh-keygen -t ed25519 -N "" -f "${config.age.secrets.initrd_host_ed25519_key.path}"
      fi
    '';
    deps = ["agenixInstall" "users"];
  };
  system.activationScripts.agenixChown.deps = ["agenixEnsureInitrdHostkey"];
}
