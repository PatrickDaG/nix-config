{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
let
  base = import ./coding-agent-jail.nix { inherit lib pkgs inputs; };
  inherit (base) jail;
  herdrHook = "${config.home.homeDirectory}/.codex/herdr-agent-state.sh";
  herdrPackage = pkgs.llm-agents.herdr;
  jailed-codex = jail "jailed-codex" pkgs.llm-agents.codex (
    base.baseCombinators
    ++ base.herdrCombinators "codex"
    ++ (with jail.combinators; [
      (readwrite (noescape "~/.codex"))
      (set-argv [
        (noescape "--yolo")
        (noescape "\"$@\"")
      ])
    ])
  );
in
{
  home.file.".codex/herdr-agent-state.sh".source =
    "${herdrPackage}/share/herdr/integrations/codex/herdr-agent-state.sh";

  programs.codex = {
    enable = true;
    package = jailed-codex;
    hooks.SessionStart = [
      {
        hooks = [
          {
            type = "command";
            command = "bash ${lib.escapeShellArg herdrHook} session";
            timeout = 10;
          }
        ];
      }
    ];
    settings.features.hooks = true;
  };
}
