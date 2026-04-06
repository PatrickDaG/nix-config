{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.programs.pi;
  jsonFormat = pkgs.formats.json { };

  # --- YAML frontmatter helpers ---
  toYamlValue =
    v:
    if lib.isBool v then
      (if v then "true" else "false")
    else if lib.isInt v then
      toString v
    else
      builtins.toJSON v;

  # --- Build SKILL.md content ---
  mkSkillMdContent =
    name: skill:
    let
      frontmatterEntries = [
        "name: ${name}"
        "description: ${builtins.toJSON skill.description}"
      ]
      ++ lib.optional (skill.license != null) "license: ${builtins.toJSON skill.license}"
      ++ lib.optional (
        skill.compatibility != null
      ) "compatibility: ${builtins.toJSON skill.compatibility}"
      ++ lib.optional (skill.allowedTools != null) "allowed-tools: ${builtins.toJSON skill.allowedTools}"
      ++ lib.optional skill.disableModelInvocation "disable-model-invocation: true"
      ++ lib.concatLists (lib.mapAttrsToList (k: v: [ "${k}: ${toYamlValue v}" ]) skill.extraFrontmatter);
    in
    lib.concatStringsSep "\n" [
      "---"
      (lib.concatStringsSep "\n" frontmatterEntries)
      "---"
      ""
      skill.content
    ];

  # --- Build skills derivation ---
  skillsDrv =
    let
      skillPkgs = lib.mapAttrsToList (
        name: skill:
        let
          skillMd = pkgs.writeText "SKILL-${name}.md" (mkSkillMdContent name skill);
        in
        pkgs.runCommand "pi-skill-${name}" { } (
          ''
            mkdir -p $out/${name}
            cp ${skillMd} $out/${name}/SKILL.md
          ''
          + lib.concatStringsSep "\n" (
            lib.mapAttrsToList (fname: src: ''
              mkdir -p "$out/${name}/$(dirname "${fname}")"
              cp -rL ${src} "$out/${name}/${fname}"
            '') skill.files
          )
        )
      ) cfg.skills;
    in
    pkgs.symlinkJoin {
      name = "pi-nix-skills";
      paths = skillPkgs;
    };

  # --- Build prompts derivation ---
  promptsDrv =
    let
      promptPkgs = lib.mapAttrsToList (
        name: prompt:
        let
          content =
            (lib.optionalString (
              prompt.description != null
            ) "---\ndescription: ${builtins.toJSON prompt.description}\n---\n")
            + prompt.content;
        in
        pkgs.writeTextDir "${name}.md" content
      ) cfg.prompts;
    in
    pkgs.symlinkJoin {
      name = "pi-nix-prompts";
      paths = promptPkgs;
    };

  # --- Build themes derivation ---
  themesDrv =
    let
      themePkgs = lib.mapAttrsToList (
        name: theme: pkgs.writeTextDir "${name}.json" (builtins.toJSON theme)
      ) cfg.themes;
    in
    pkgs.symlinkJoin {
      name = "pi-nix-themes";
      paths = themePkgs;
    };

  # --- Build extensions derivation ---
  extensionsDrv =
    let
      extPkgs = lib.mapAttrsToList (
        name: ext:
        if ext.text != null then
          pkgs.writeTextDir "${name}.ts" ext.text
        else
          pkgs.runCommand "pi-ext-${name}" { } ''
            mkdir -p $out
            src="${ext.source}"
            if [ -d "$src" ]; then
              cp -rL "$src"/. "$out/${name}/"
            else
              cp -L "$src" "$out/${name}.ts"
            fi
          ''
      ) cfg.extensions;
    in
    pkgs.symlinkJoin {
      name = "pi-nix-extensions";
      paths = extPkgs;
    };

  # --- Compute resource path additions for settings ---
  resourcePaths = lib.filterAttrs (_: v: v != [ ]) {
    skills = lib.optional (cfg.skills != { }) "${skillsDrv}" ++ cfg.extraSkillPaths;
    prompts = lib.optional (cfg.prompts != { }) "${promptsDrv}" ++ cfg.extraPromptPaths;
    themes = lib.optional (cfg.themes != { }) "${themesDrv}" ++ cfg.extraThemePaths;
    extensions = lib.optional (cfg.extensions != { }) "${extensionsDrv}" ++ cfg.extraExtensionPaths;
  };

  nixSettings = lib.recursiveUpdate cfg.settings resourcePaths;

  # Keys whose arrays get merge behavior (clean /nix/store/ entries, then prepend nix entries)
  resourceKeys = [
    "skills"
    "prompts"
    "themes"
    "extensions"
  ];

  mergeJqFilter = ''
    # For resource arrays: remove old /nix/store/ entries from existing, then prepend nix entries
    def merge_resource_array($key):
      ((.[$key] // []) | map(select(
        if type == "string" then (startswith("/nix/store/") | not)
        else true end
      ))) as $clean |
      ($nix[$key] // []) + $clean;

    # Separate nix settings into resource arrays and the rest
    ($nix | with_entries(select(.key | IN(${
      lib.concatMapStringsSep "," (k: ''"${k}"'') resourceKeys
    }) | not))) as $nix_rest |

    # Deep merge non-array settings (nix wins)
    (. * $nix_rest) |

    # Merge resource arrays
    ${lib.concatMapStringsSep " |\n    " (
      k: ''if ($nix | has("${k}")) then .${k} = merge_resource_array("${k}") else . end''
    ) resourceKeys}
  '';
in
{
  options.programs.pi = {
    enable = lib.mkEnableOption "pi coding agent configuration";

    package = lib.mkPackageOption pkgs "pi" { };

    agentsPrompt = lib.mkOption {
      type = lib.types.nullOr lib.types.lines;
      default = null;
      example = lib.literalExpression ''
        '''
          # Global Instructions

          - Always use conventional commits
          - Prefer functional style
          - Run `nix fmt` before committing
        '''
      '';
      description = ''
        Content for the global `~/.pi/agent/AGENTS.md` context file.

        Pi loads this at startup and includes it in the system prompt.
        Use for global conventions, instructions, and preferences that
        apply to all projects.

        Project-level `AGENTS.md` files (in cwd and parent directories)
        are loaded in addition to this global file.
      '';
    };

    systemPrompt = lib.mkOption {
      type = lib.types.nullOr lib.types.lines;
      default = null;
      description = ''
        Content for `~/.pi/agent/SYSTEM.md`.

        Replaces the default system prompt entirely.
        Use `appendSystemPrompt` to append without replacing.
      '';
    };

    appendSystemPrompt = lib.mkOption {
      type = lib.types.nullOr lib.types.lines;
      default = null;
      description = ''
        Content for `~/.pi/agent/APPEND_SYSTEM.md`.

        Appended to the default system prompt without replacing it.
      '';
    };

    settings = lib.mkOption {
      inherit (jsonFormat) type;
      default = { };
      example = lib.literalExpression ''
        {
          defaultProvider = "anthropic";
          defaultModel = "claude-sonnet-4-20250514";
          defaultThinkingLevel = "medium";
          theme = "dark";
          quietStartup = true;
          compaction = {
            enabled = true;
            reserveTokens = 16384;
            keepRecentTokens = 20000;
          };
          retry = {
            enabled = true;
            maxRetries = 3;
          };
          enabledModels = [ "claude-*" "gpt-4o" ];
          packages = [ "pi-skills" ];
        }
      '';
      description = ''
        Settings merged into `~/.pi/agent/settings.json`.

        Nix-managed keys take precedence over imperative values.
        Imperative keys not managed by nix are preserved across activations.

        Resource path arrays (`skills`, `prompts`, `themes`, `extensions`) are
        merged specially: nix store paths from previous activations are replaced,
        while user-added paths are preserved.

        See https://github.com/badlogic/pi-mono for all available settings.
      '';
    };

    keybindings = lib.mkOption {
      type = lib.types.attrsOf (lib.types.either lib.types.str (lib.types.listOf lib.types.str));
      default = { };
      example = lib.literalExpression ''
        {
          "tui.editor.cursorUp" = [ "up" "ctrl+p" ];
          "tui.editor.cursorDown" = [ "down" "ctrl+n" ];
          "tui.editor.cursorLeft" = [ "left" "ctrl+b" ];
          "tui.editor.cursorRight" = [ "right" "ctrl+f" ];
          "app.model.cycleForward" = "ctrl+p";
        }
      '';
      description = ''
        Keybindings merged into `~/.pi/agent/keybindings.json`.

        Nix-managed keys take precedence. Imperative keybindings for
        keys not declared here are preserved.

        Each action can be bound to a single key string or a list of key strings.
        Format: `modifier+key` where modifiers are `ctrl`, `shift`, `alt`.
      '';
    };

    skills = lib.mkOption {
      type = lib.types.attrsOf (
        lib.types.submodule {
          options = {
            description = lib.mkOption {
              type = lib.types.str;
              description = ''
                What this skill does and when to use it (max 1024 chars).
                This determines when the agent loads the skill, so be specific.
              '';
            };

            content = lib.mkOption {
              type = lib.types.lines;
              description = "Markdown body of SKILL.md (everything after the frontmatter).";
            };

            license = lib.mkOption {
              type = lib.types.nullOr lib.types.str;
              default = null;
              description = "License name or reference to bundled file.";
            };

            compatibility = lib.mkOption {
              type = lib.types.nullOr lib.types.str;
              default = null;
              description = "Environment requirements (max 500 chars).";
            };

            allowedTools = lib.mkOption {
              type = lib.types.nullOr lib.types.str;
              default = null;
              description = "Space-delimited list of pre-approved tools (experimental).";
            };

            disableModelInvocation = lib.mkOption {
              type = lib.types.bool;
              default = false;
              description = "When true, skill is hidden from system prompt. Users must use `/skill:name`.";
            };

            extraFrontmatter = lib.mkOption {
              type = lib.types.attrsOf jsonFormat.type;
              default = { };
              description = "Additional YAML frontmatter fields.";
            };

            files = lib.mkOption {
              type = lib.types.attrsOf lib.types.path;
              default = { };
              example = lib.literalExpression ''
                {
                  "scripts/search.js" = ./skills/brave-search/search.js;
                  "scripts/content.js" = ./skills/brave-search/content.js;
                }
              '';
              description = ''
                Additional files to include in the skill directory.
                Keys are relative paths within the skill directory.
              '';
            };
          };
        }
      );
      default = { };
      example = lib.literalExpression ''
        {
          nix-helper = {
            description = "Helps with NixOS configuration, flakes, and home-manager. Use when working with .nix files.";
            content = '''
              # Nix Helper

              ## Usage
              - Check syntax: `nix flake check`
              - Format: `nix fmt`
              - Build: `nix build`
            ''';
          };
        }
      '';
      description = ''
        Skill definitions. Each attribute name is the skill name
        (lowercase letters, numbers, hyphens only; max 64 chars; must match directory name).

        Skills are built into the nix store and added to pi via the settings
        `skills` array. Imperative skills in `~/.pi/agent/skills/` are
        unaffected and continue to work alongside nix-managed ones.
      '';
    };

    prompts = lib.mkOption {
      type = lib.types.attrsOf (
        lib.types.submodule {
          options = {
            description = lib.mkOption {
              type = lib.types.nullOr lib.types.str;
              default = null;
              description = "Optional description shown in autocomplete. If omitted, the first line is used.";
            };

            content = lib.mkOption {
              type = lib.types.lines;
              description = ''
                Prompt template content. Supports positional arguments:
                `$1`, `$2` for positional; `$@` for all args; `''${@:N}` for args from Nth position.
              '';
            };
          };
        }
      );
      default = { };
      example = lib.literalExpression ''
        {
          review = {
            description = "Review staged git changes";
            content = '''
              Review the staged changes (`git diff --cached`). Focus on:
              - Bugs and logic errors
              - Security issues
              - Error handling gaps
            ''';
          };
          component = {
            description = "Create a new component";
            content = "Create a component named $1 with features: $@";
          };
        }
      '';
      description = ''
        Prompt template definitions. Each attribute name becomes the `/command` name.

        Templates are built into the nix store and added to pi via the settings
        `prompts` array. Imperative templates in `~/.pi/agent/prompts/` are
        unaffected.
      '';
    };

    themes = lib.mkOption {
      type = lib.types.attrsOf jsonFormat.type;
      default = { };
      example = lib.literalExpression ''
        {
          my-theme = {
            name = "my-theme";
            vars = {
              primary = "#00aaff";
              secondary = 242;
            };
            colors = {
              accent = "primary";
              border = "primary";
              # ... all 51 color tokens required
            };
          };
        }
      '';
      description = ''
        Theme definitions. Each attribute name is the theme name.
        Value is the full theme JSON object including all 51 required color tokens.

        Themes are built into the nix store and added to pi via the settings
        `themes` array. Imperative themes in `~/.pi/agent/themes/` are unaffected.
      '';
    };

    extensions = lib.mkOption {
      type = lib.types.attrsOf (
        lib.types.submodule {
          options = {
            source = lib.mkOption {
              type = lib.types.nullOr lib.types.path;
              default = null;
              description = ''
                Path to extension file (`.ts`/`.js`) or directory (must contain `index.ts`).
                Mutually exclusive with `text`.
              '';
            };

            text = lib.mkOption {
              type = lib.types.nullOr lib.types.lines;
              default = null;
              description = ''
                Inline TypeScript source for a single-file extension.
                Mutually exclusive with `source`.
              '';
            };
          };
        }
      );
      default = { };
      example = lib.literalExpression ''
        {
          confirm-destructive = {
            text = '''
              import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";

              export default function (pi: ExtensionAPI) {
                pi.on("tool_call", async (event, ctx) => {
                  if (event.toolName === "bash" && event.input.command?.includes("rm -rf")) {
                    const ok = await ctx.ui.confirm("Dangerous!", "Allow rm -rf?");
                    if (!ok) return { block: true, reason: "Blocked by user" };
                  }
                });
              }
            ''';
          };
        }
      '';
      description = ''
        Extension definitions. Each attribute name is the extension name.
        Exactly one of `source` or `text` must be set.

        Extensions are built into the nix store and added to pi via the settings
        `extensions` array. Imperative extensions in `~/.pi/agent/extensions/`
        are unaffected.

        **Security:** Extensions run with full system permissions. Only use
        trusted code.
      '';
    };

    extraSkillPaths = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      example = [
        "~/.claude/skills"
        "/opt/shared-skills"
      ];
      description = "Additional paths to add to the `skills` settings array.";
    };

    extraPromptPaths = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "Additional paths to add to the `prompts` settings array.";
    };

    extraThemePaths = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "Additional paths to add to the `themes` settings array.";
    };

    extraExtensionPaths = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "Additional paths to add to the `extensions` settings array.";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ cfg.package ];

    warnings = lib.concatLists (
      lib.mapAttrsToList (
        name: ext:
        lib.optional (
          (ext.source == null) == (ext.text == null)
        ) "programs.pi.extensions.${name}: exactly one of 'source' or 'text' must be set."
      ) cfg.extensions
    );

    # Context files: AGENTS.md, SYSTEM.md, APPEND_SYSTEM.md
    # These are pure content files pi reads but never writes, so symlinks are fine.
    home.file = lib.filterAttrs (_: v: v != null) {
      ".pi/agent/AGENTS.md" = lib.mkIf (cfg.agentsPrompt != null) {
        text = cfg.agentsPrompt;
      };
      ".pi/agent/SYSTEM.md" = lib.mkIf (cfg.systemPrompt != null) {
        text = cfg.systemPrompt;
      };
      ".pi/agent/APPEND_SYSTEM.md" = lib.mkIf (cfg.appendSystemPrompt != null) {
        text = cfg.appendSystemPrompt;
      };
    };

    # Activation script to merge nix-managed config with imperative state
    home.activation.piSettings = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      PI_DIR="$HOME/.pi/agent"
      run mkdir -p "$PI_DIR"

      # --- Merge settings.json ---
      SETTINGS_FILE="$PI_DIR/settings.json"
      NIX_SETTINGS='${builtins.toJSON nixSettings}'

      if [ -f "$SETTINGS_FILE" ]; then
        EXISTING=$(cat "$SETTINGS_FILE" 2>/dev/null || echo '{}')
      else
        EXISTING='{}'
      fi

      echo "$EXISTING" | ${lib.getExe pkgs.jq} --argjson nix "$NIX_SETTINGS" '
        ${mergeJqFilter}
      ' > "$SETTINGS_FILE.tmp" && mv "$SETTINGS_FILE.tmp" "$SETTINGS_FILE"

      verboseEcho "pi: merged settings.json"

      # --- Merge keybindings.json ---
      ${lib.optionalString (cfg.keybindings != { }) ''
        KB_FILE="$PI_DIR/keybindings.json"
        NIX_KB='${builtins.toJSON cfg.keybindings}'

        if [ -f "$KB_FILE" ]; then
          KB_EXISTING=$(cat "$KB_FILE" 2>/dev/null || echo '{}')
        else
          KB_EXISTING='{}'
        fi

        echo "$KB_EXISTING" | ${lib.getExe pkgs.jq} --argjson nix "$NIX_KB" '. * $nix' \
          > "$KB_FILE.tmp" && mv "$KB_FILE.tmp" "$KB_FILE"

        verboseEcho "pi: merged keybindings.json"
      ''}
    '';
  };
}
