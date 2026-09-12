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

- You are running in a sandbox. Edits outside `$PWD` and the active agent's directory (`$HOME/.pi` for Pi, `$HOME/.omp` for Oh My Pi) will not persist. If such edits are needed, ask the user to relax the sandbox.
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

