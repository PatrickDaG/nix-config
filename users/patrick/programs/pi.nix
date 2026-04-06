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

      # Nix support: expose the full nix store (read-only),
      # the daemon socket, and caches so nix builds work inside the sandbox.
      (readonly "/nix/store")
      (readwrite "/nix/var/nix/daemon-socket")
      # noesacpe needed to expand ~
      (readwrite (noescape "~/.cache/nix"))
      (readonly "/etc/nix")
      (readonly "/etc/static/nix")
      (try-fwd-env "NIX_PATH")
      (set-env "NIX_REMOTE" "daemon")

      (readonly (noescape "~/.config/jj"))

      # GitHub CLI auth for PR interactions (separate account from host)
      # Uses ~/.config/gh-pi so the sandbox gets its own gh identity.
      (readwrite (noescape "~/.config/gh-pi"))
      (set-env "NIX_REMOTE" (noescape "~/.config/gh-pi"))

      (add-pkg-deps (
        with pkgs;
        [
          # keep-sorted start
          bashInteractive
          curl
          diffutils
          findutils
          gawkInteractive
          gh
          git
          gnugrep
          gnutar
          gzip
          jq
          jujutsu
          nix
          nixpkgs-review
          ps
          python3
          ripgrep
          unzip
          which
          # keep-sorted end
        ]
      ))
    ]
  );

in
{
  hm.home.persistence."/state".directories = [ ".config/gh-pi" ];

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
      - ALWAYS DO THIS: at the start of each session, create a new `jj` workspace in the current directory (`jj workspace add`) and work within it.
    '';

    prompts.nixpkgs-review = {
      description = "Review a nixpkgs pull request for quality, correctness, and adherence to best practices";
      content = ''
        You are a nixpkgs pull request reviewer. Your job is to thoroughly review PR #$1 against the nixpkgs repository.

        **You must NOT modify any files.** Your output is a review with actionable findings only.

        ## Environment

        You are in a jj checkout of the nixpkgs repository. Use `jj` for all VCS operations (not git).

        ## Step 1: Fetch and understand the PR

        First, gather PR metadata from GitHub:
        ```
        gh pr view $1 --json title,body,files,commits,labels,reviews,comments
        ```

        Read the PR description, linked issues, and all discussion comments carefully to understand intent.

        ## Step 2: Check out the PR changes locally

        Fetch and inspect the diff without modifying the working tree:
        ```
        gh pr diff $1
        ```

        Review every changed file in the diff. For deeper inspection of specific files, read them from the PR branch:
        ```
        gh pr diff $1 --name-only
        ```
        Then read each changed file to understand surrounding context.

        ## Step 3: Build with nixpkgs-review

        Use `nixpkgs-review` to verify the PR builds correctly:
        ```
        nixpkgs-review pr $1
        ```

        This will:
        - Fetch the PR and determine affected packages
        - Build all affected packages
        - Report build successes and failures

        Carefully examine any build failures and include them in your review.

        ## Step 4: Review against nixpkgs standards

        Evaluate the PR against the following official documentation and policies. Read the relevant sections from the local nixpkgs tree:

        ### Packaging conventions
        - `doc/languages-frameworks/` — language-specific packaging guides (python, rust, go, haskell, node, etc.)
        - `doc/stdenv/` — stdenv phases, meta attributes, cross-compilation
        - `doc/build-helpers/` — fetchers, trivial builders, `makeWrapper`, etc.
        - `pkgs/README.md` — top-level packaging conventions

        ### Contributing standards
        - `CONTRIBUTING.md` — commit message format, PR conventions, review process
        - `.github/CODEOWNERS` — check if appropriate maintainers are requested
        - `.github/PULL_REQUEST_TEMPLATE.md` — verify PR description completeness

        ### Specific checks to perform

        **Package metadata (`meta` attribute):**
        - `description` is present and concise (no "A" or "An" prefix, no period at end)
        - `homepage` is set and valid
        - `license` uses values from `lib.licenses`
        - `maintainers` list includes the PR author or appropriate maintainers from `maintainers/maintainer-list.nix`
        - `platforms` is set appropriately
        - `mainProgram` is set if the package provides a binary

        **Source integrity:**
        - Fetcher is appropriate (`fetchFromGitHub`, `fetchurl`, `fetchpatch`, etc.)
        - `hash` uses SRI format (not legacy `sha256` string when avoidable)
        - Version matches upstream tag/release
        - Patches are minimal and well-justified

        **Build correctness:**
        - Correct builder/framework used for the language ecosystem
        - Dependencies are complete (native vs build vs runtime)
        - No unnecessary `fixupPhase` or `postInstall` hacks
        - Tests are enabled where possible (`doCheck = true`, `pytestCheckHook`, etc.)
        - `passthru.tests` or `passthru.updateScript` where applicable

        **NixOS module quality (if applicable):**
        - Read `doc/README.md` for module documentation conventions
        - Options use proper types from `lib.types`
        - Options have `description`, `default`, and `example` where appropriate
        - `mkEnableOption` / `mkPackageOption` used correctly
        - Service hardening (systemd sandboxing, `DynamicUser`, `StateDirectory`, etc.)
        - Freeform settings pattern used where appropriate (`settingsFormat`)

        **Code style:**
        - Follows nixpkgs formatting (nixfmt-rfc-style)
        - `lib` functions used properly (no `with lib;` in new code, prefer qualified access)
        - `callPackage` pattern used for package definitions
        - File is in the correct location under `pkgs/by-name/` (two-letter prefix convention) for new packages
        - `by-name` packages must NOT set `pname`/`name` redundantly if directory name suffices

        **Commit hygiene:**
        - Commit message follows `category: description` format (e.g., `python3Packages.foo: init at 1.0.0`)
        - One logical change per commit
        - Version updates include a changelog link or summary of changes

        **Security considerations:**
        - No vendored binaries or prebuilt artifacts without justification
        - No `allowBroken`, `insecure`, or `unfree` additions without rationale
        - Patches reviewed for safety

        ## Step 5: Produce the review

        Output a structured review in this format:

        ```markdown
        # Review: PR #$1 — <title>

        ## Summary
        <Brief description of what the PR does and your overall assessment>

        ## Build Results
        <Output from nixpkgs-review: which packages built, which failed>

        ## Findings

        ### Blockers (must fix before merge)
        - [ ] <issue with file path and line reference>

        ### Suggestions (should fix, non-blocking)
        - [ ] <improvement with rationale>

        ### Nits (style, optional)
        - [ ] <minor style issue>

        ### Positive observations
        - <things done well>

        ## Verdict
        <APPROVE / REQUEST_CHANGES / NEEDS_DISCUSSION — with rationale>
        ```

        Be specific: always reference file paths, line numbers, and quote relevant code snippets.
        Cite the specific nixpkgs documentation section when flagging an issue.
        If everything looks good, say so — don't invent problems.
      '';
    };
  };
}
