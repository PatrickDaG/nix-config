{
  config,
  lib,
  nodes,
  ...
}:
let
  inherit (lib)
    attrNames
    concatMap
    concatStringsSep
    foldl'
    getAttrFromPath
    mkMerge
    mkOption
    mkOptionType
    optionals
    recursiveUpdate
    setAttrByPath
    types
    ;

  nodeName = config.node.name;
  mkForwardedOption =
    path:
    mkOption {
      type = mkOptionType {
        name = "Same type that the receiving option `${concatStringsSep "." path}` normally accepts.";
        merge =
          _loc: defs:
          builtins.filter (x: builtins.isAttrs x -> ((x._type or "") != "__distributed_config_empty")) (
            map (x: x.value) defs
          );
      };
      default = {
        _type = "__distributed_config_empty";
      };
      description = ''
        Anything specified here will be forwarded to `${concatStringsSep "." path}`
        on the given node. Forwarding happens as-is to the raw values,
        so validity can only be checked on the receiving node.
      '';
    };

  forwardedOptions = [
    [
      "age"
      "secrets"
    ]
    [
      "services"
      "idmail"
      "provision"
      "mailboxes"
    ]
    [
      "services"
      "influxdb2"
      "provision"
      "organizations"
    ]
  ];

  attrsForEachOption =
    f: (foldl' (acc: path: recursiveUpdate acc (setAttrByPath path (f path))) { } forwardedOptions);
in
{
  options.nodes = mkOption {
    description = "Options forwareded to the given node.";
    default = { };
    type = types.attrsOf (types.submodule { options = attrsForEachOption mkForwardedOption; });
  };

  config =
    let
      mergeConfigFromOthers =
        let
          getConfig =
            path: otherNode:
            let
              cfg = nodes.${otherNode}.config.nodes.${nodeName} or null;
            in
            optionals (cfg != null) (getAttrFromPath path cfg);
        in
        path: mkMerge (concatMap (getConfig path) (attrNames nodes));
    in
    attrsForEachOption mergeConfigFromOthers;
}
