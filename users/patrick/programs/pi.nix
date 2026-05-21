{
  lib,
  pkgs,
  inputs,
  ...
}:
let
  base = import ./coding-agent-jail.nix { inherit lib pkgs inputs; };
  inherit (base) jail;
  kagi = inputs.kagi.packages.${pkgs.stdenv.hostPlatform.system}.kagi-release;
  jailed-pi = jail "jailed-pi" pkgs.llm-agents.pi (
    base.baseCombinators
    ++ (with jail.combinators; [
      (readwrite (noescape "~/.pi"))
      (try-fwd-env "KAGI_SESSION_LINK")
      (try-fwd-env "KAGI_SESSION_TOKEN")
      (add-pkg-deps [ kagi ])
    ])
  );

in
{
  hm.home.persistence."/state".directories = [ ".config/gh-pi" ];

  hm.programs.pi = {
    enable = true;

    package = jailed-pi;

    settings = { };

    skills.kagi-web-search = {
      description = "Search the web with Kagi. Use when current external information, web pages, or general internet research are needed.";
      content = ''
        # Kagi Web Search

        Use the `kagi` CLI through `bash` for web searches.

        ## Commands

        - Search with quick answer and links:
          ```bash
          kagi --quick-answer --links --num-results 5 --json "search query"
          ```
        - Search only links:
          ```bash
          kagi --links --num-results 10 --json "search query"
          ```

        ## Guidance

        - Prefer `--json` so results are structured.
        - Quote the query as one argument.
        - Summarize results and cite returned URLs.
        - If auth fails, tell the user to set `KAGI_SESSION_TOKEN` or `KAGI_SESSION_LINK` before starting pi.
      '';
    };

    agentsPrompt = ''
      # Output format
      Respond brief in chat replies. Commit messages, code, and comments use normal English.

      - Drop articles (a, an, the), filler (just, really, basically, actually).
      - Drop pleasantries (sure, certainly, happy to).
      - No hedging. Fragments fine. Short synonyms.
      - Technical terms stay exact. Code blocks unchanged.
      - Pattern: [thing] [action] [reason]. [next step].

      # Ask, Don't Assume

      When a request is ambiguous, has multiple valid approaches, or the scope is unclear — stop and ask before doing anything. Specific triggers:

          - Requirements could be interpreted multiple ways → ask which one
          - Multiple valid implementation approaches exist → list them, ask preference
          - Scope is unclear (how much to change, which files) → ask to narrow down
          - Not sure about existing project conventions → read existing code first, ask if still unclear
          - Task is large or vague → propose a plan and wait for approval

      Never go on a multi-file exploration spree trying to "figure it out". A 10-second question saves a 10-minute goose chase.

      # Always Re-read Before Editing

      - Always re-read a file before editing it — the user may have changed it
      - Never assume file contents from memory. Files change between turns
      - If an edit fails, re-read the file before retrying


      # Sandboxing

      - You are running in a sandbox. Edits outside `$PWD` and `$HOME/.pi` will not persist. If such edits are needed, ask the user to relax the sandbox.
      - Your parent directory(the main jujutsu repository) is not part of the sandbox, DO NOT try reading/editing it. Contain everything in the current workspace.
      - Commands may fail due to missing permission or secrets. DO NOT try again. Instead tell the user what went wrong, what is missing and wait for further instructions.

      # Available Tools

      - These basic tools are always available: fd, rg, jq, gh, tea, diff, jj, nix
      - For further tools use 'nix run'

      # Style guide

      - Markdown files should have a maximum line width of 170 characters

      # VCS

      - Use jujutsu instead of git
      - Sync the repository after every change by running 'jj status'
      - Set a description using "jj describe -m"
      - Use conventional commit messages(e.g. prefix of feat/fix/chore)
      - Always add an "Assisted-by:" commit message trailer containing tool name and the exact model name and version used for the contribution
      - Use gh for GitHub
      - use tea for gitea/forgejo

      # Search

      - Recommended: Use GitHub code search to find examples for libraries and APIs: gh search code "foo lang:nix".
      - Prefer cloning source code over web searches for more accurate results.


      # General Guidelines

      Follow XDG Base Directory spec for config/cache/data paths when writing code.

      # Nix

      - Use nix-based tooling whenever possible (flakes, devshells, `nix` command).
      - Use nix log /nix/store/xxxx | grep <key-word> to inspect failed nix builds
      - Add new untracked files in Nix flakes with git add.
      - To get a rebuild of a nix package change the nix expression instead of --rebuild
      - Prefer nix-provided Python deps over pip/venv when packaging or scripting.
      - Inside nix-shell/nix develop: locate headers/libs/tools via env vars (e.g. env | rg /nix/store, $NIX_CFLAGS_COMPILE, $PKG_CONFIG_PATH, $buildInputs) rather than guessing system paths.
      - Use nix-locate to find packages by path, e.g. nix-locate bin/ip
      - Use nix run to execute applications that are not installed.
      - Use nix eval instead of nix flake show to look up attributes in a flake.
      - nix flake check runs too slow. Instead, build individual tests.

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
