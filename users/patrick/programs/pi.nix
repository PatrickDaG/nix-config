{ pkgs, inputs, ... }:
let
  jail = inputs.jail-nix.lib.init pkgs;
  jailed-pi = jail "jailed-pi" pkgs.llm-agents.pi (
    with jail.combinators;
    [
      network
      time-zone
      no-new-session
      mount-cwd
      (readwrite (noescape "~/.pi"))
      (add-pkg-deps (
        with pkgs;
        [
          bashInteractive
          curl
          git
          jq
          ripgrep
          gnugrep
          findutils
          diffutils
          which
          gzip
          unzip
          gnutar
          gawkInteractive
          ps
        ]
      ))
    ]
  );
in
{
  hm.programs.pi = {
    enable = true;

    package = jailed-pi;

    settings = {
      defaultProvider = "anthropic";
      defaultModel = "claude-opus-4-6";
      defaultThinkingLevel = "medium";
    };
  };
}
