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
  herdrHook = "${config.home.homeDirectory}/.claude/hooks/herdr-agent-state.sh";
  herdrPackage = pkgs.llm-agents.herdr;
  jclaude = jail "jclaude" pkgs.llm-agents.claude-code (
    base.baseCombinators
    ++ base.herdrCombinators "claude"
    ++ (with jail.combinators; [
      (readwrite (noescape "~/.claude"))
      (readwrite (noescape "~/.claude.json"))
      (readwrite (noescape "~/.claude.json.backup"))
      (set-argv [
        (noescape "--dangerously-skip-permissions")
        (noescape "\"$@\"")
      ])
    ])
  );
in
{
  home.file.".claude/hooks/herdr-agent-state.sh".source =
    "${herdrPackage}/share/herdr/integrations/claude/herdr-agent-state.sh";

  programs.claude-code = {
    enable = true;
    package = jclaude;
    settings.hooks.SessionStart = [
      {
        matcher = "^(startup|resume|clear|compact|fork)$";
        hooks = [
          {
            type = "command";
            command = "bash ${lib.escapeShellArg herdrHook} session";
            timeout = 10;
          }
        ];
      }
    ];
  };
}
