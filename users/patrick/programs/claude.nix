{ pkgs, inputs, ... }:
let
  base = import ./coding-agent-jail.nix { inherit pkgs inputs; };
  inherit (base) jail;
  jailed-claude = jail "jailed-claude" pkgs.llm-agents.claude-code (
    base.baseCombinators
    ++ (
      with jail.combinators;
      [
        (readwrite (noescape "~/.claude"))
        (readwrite (noescape "~/.claude.json"))
        (readwrite (noescape "~/.claude.json.backup"))
        (set-argv [
          (noescape "--dangerously-skip-permissions")
          (noescape "\"$@\"")
        ])
      ]
    )
  );
in
{
  hm.programs.claude-code = {
    enable = true;
    package = jailed-claude;
  };
}
