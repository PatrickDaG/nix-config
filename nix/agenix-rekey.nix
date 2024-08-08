{ inputs, self, ... }:
{
  imports = [ inputs.agenix-rekey.flakeModule ];
  flake = {
    secretsConfig = {
      # This should be a link to one of the age public keys in './keys'
      masterIdentities = [ ../keys/PatC.pub ];
      extraEncryptionPubkeys = [ ../secrets/recipients.txt ];
    };
  };
  perSystem =
    { config, ... }:
    {
      agenix-rekey.nodes = self.nodes;
      devshells.default = {
        commands = [
          {
            inherit (config.agenix-rekey) package;
            help = "Edit, generate and rekey secrets";
          }
        ];
        env = [
          {
            # Always add files to git after agenix rekey and agenix generate.
            name = "AGENIX_REKEY_ADD_TO_GIT";
            value = "true";
          }
        ];
      };
    };
}
