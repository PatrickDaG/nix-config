{ inputs, self, ... }:
{
  imports = [ inputs.agenix-rekey.flakeModule ];
  flake = {
    secretsConfig = {
      masterIdentities = [ ../keys/PatC.pub ../keys/PatA.pub ];
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
