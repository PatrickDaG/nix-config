{
  lib,
  pkgs,
  inputs,
  ...
}:
let
  base = import ./coding-agent-jail.nix { inherit lib pkgs inputs; };
  inherit (base) jail;
  jailed-codex = jail "jailed-codex" pkgs.llm-agents.codex (
    base.baseCombinators
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
  hm.programs.codex = {
    enable = true;
    package = jailed-codex;
  };
}
