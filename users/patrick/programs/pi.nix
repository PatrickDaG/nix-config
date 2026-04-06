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
          # keep-sorted start
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
          jujutsu
          gawkInteractive
          ps
          # keep-sorted end
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

    agentsPrompt = ''
      - Use nix-based tooling whenever possible (flakes, devshells, `nix` command).
      - You are running in a sandbox. Edits outside `$PWD` and `$HOME/.pi` will not persist. If such edits are needed, ask the user to relax the sandbox.
      - ALWAYS DO THIS: at the start of each session, create a new `jj` changeset (`jj new`) and work within it.
    '';
  };
}
