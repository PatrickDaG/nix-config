{
  lib,
  options,
  ...
}:
let
  inherit (lib)
    mkOption
    types
    ;

in
{
  options = {
    globals = mkOption {
      default = { };
      type = types.submodule {
        options = {
          accounts.email = mkOption {
            # Not really, should be the same type as the home-manager accounts.email option
            # Just don't wann copy the whole definition
            type = types.attrs;
            default = { };
          };
          domains = mkOption {
            type = types.attrsOf types.str;
            default = { };
          };
          hosts = mkOption {
            type = types.attrsOf (
              types.submodule {
                options = {
                  ip = mkOption {
                    type = types.nullOr types.net.ipv4;
                    default = null;
                    description = "The public IP of this host";
                  };
                };
              }
            );
          };
          users = mkOption {
            type = types.attrsOf (
              types.submodule {
                options = {
                  hashedPassword = mkOption {
                    type = types.nullOr types.str;
                    default = null;
                    description = "The public IP of this host";
                  };
                };
              }
            );
          };
          hetzner = mkOption {
            default = { };
            description = "Storage box configurations.";
            type = types.submodule {
              options = {
                mainUser = mkOption {
                  type = types.str;
                  description = "Main username for the storagebox";
                };

                users = mkOption {
                  default = { };
                  description = "Subuser configurations.";
                  type = types.attrsOf (
                    types.submodule {
                      options = {
                        subUid = mkOption {
                          type = types.int;
                          description = "The subuser id";
                        };

                        path = mkOption {
                          type = types.str;
                          description = "The home path for this subuser (i.e. backup destination)";
                        };
                      };
                    }
                  );
                };
              };
            };
          };
          net.vlans = mkOption {
            default = { };
            type = types.attrsOf (
              types.submodule (vlanNetSubmod: {
                options = {
                  id = mkOption {
                    type = types.ints.between 1 4094;
                    description = "The VLAN id";
                  };

                  cidrv4 = mkOption {
                    type = types.nullOr types.net.cidrv4;
                    default = null;
                    description = "The CIDRv4 of this vlan";
                  };
                  cidrv6 = mkOption {
                    type = types.nullOr types.net.cidrv6;
                    default = null;
                    description = "The CIDRv6 of this vlan";
                  };
                  internet = mkOption {
                    type = types.bool;
                    default = true;
                    description = "Whether this vlan is connected to the internet";
                  };

                  name = mkOption {
                    description = "The name of this VLAN";
                    default = vlanNetSubmod.config._module.args.name;
                    type = types.str;
                  };
                };
              })
            );
          };

          services = mkOption {
            type = types.attrsOf (
              types.submodule {
                options = {
                  domain = mkOption {
                    type = types.nullOr types.str;
                    description = "The domain under which this service can be reached";
                    default = null;
                  };
                  host = mkOption {
                    type = types.nullOr types.str;
                    description = "The node-name on which this service runs";
                  };
                  ip = mkOption {
                    type = types.nullOr (types.ints.between 5 49);
                    default = null;
                    description = "Optional IP in case this service runs needs a static ip. Shou";
                  };
                };
              }
            );
          };
          monitoring = {
            ping = mkOption {
              type = types.attrsOf (
                types.submodule {
                  options = {
                    hostv4 = mkOption {
                      type = types.nullOr types.str;
                      description = "The IP/hostname to ping via ipv4.";
                      default = null;
                    };

                    hostv6 = mkOption {
                      type = types.nullOr types.str;
                      description = "The IP/hostname to ping via ipv6.";
                      default = null;
                    };

                    network = mkOption {
                      type = types.str;
                      description = "The network to which this endpoint is associated.";
                    };
                  };
                }
              );
              default = { };
            };

            http = mkOption {
              type = types.attrsOf (
                types.submodule {
                  options = {
                    url = mkOption {
                      type = types.either (types.listOf types.str) types.str;
                      description = "The url to connect to.";
                    };

                    expectedStatus = mkOption {
                      type = types.int;
                      default = 200;
                      description = "The HTTP status code to expect.";
                    };

                    expectedBodyRegex = mkOption {
                      type = types.nullOr types.str;
                      description = "A regex pattern to expect in the body.";
                      default = null;
                    };

                    skipTlsVerification = mkOption {
                      type = types.bool;
                      description = "Skip tls verification when using https.";
                      default = false;
                    };

                    network = mkOption {
                      type = types.str;
                      description = "The network to which this endpoint is associated.";
                    };
                  };
                }
              );
              default = { };
            };

            dns = mkOption {
              type = types.attrsOf (
                types.submodule {
                  options = {
                    server = mkOption {
                      type = types.str;
                      description = "The DNS server to query.";
                    };

                    domain = mkOption {
                      type = types.str;
                      description = "The domain to query.";
                    };

                    record-type = mkOption {
                      type = types.str;
                      description = "The record type to query.";
                      default = "A";
                    };

                    network = mkOption {
                      type = types.str;
                      description = "The network to which this endpoint is associated.";
                    };
                  };
                }
              );
              default = { };
            };

            tcp = mkOption {
              type = types.attrsOf (
                types.submodule {
                  options = {
                    host = mkOption {
                      type = types.str;
                      description = "The IP/hostname to connect to.";
                    };

                    port = mkOption {
                      type = types.port;
                      description = "The port to connect to.";
                    };

                    network = mkOption {
                      type = types.str;
                      description = "The network to which this endpoint is associated.";
                    };
                  };
                }
              );
              default = { };
            };
          };
        };
      };
    };

    _globalsDefs = mkOption {
      type = types.unspecified;
      default = options.globals.definitions;
      readOnly = true;
      internal = true;
    };
  };
}
