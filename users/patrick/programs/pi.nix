{
  lib,
  pkgs,
  inputs,
  ...
}:
let
  base = import ./coding-agent-jail.nix { inherit lib pkgs inputs; };
  inherit (base) jail;
  herdrPackage = pkgs.llm-agents.herdr;
  jpi = jail "jpi" pkgs.llm-agents.pi (
    base.baseCombinators
    ++ base.herdrCombinators "pi"
    ++ (with jail.combinators; [
      (readwrite (noescape "~/.pi"))
    ])
  );
  jomp = jail "jomp" inputs.omp.packages.x86_64-linux.omp (
    base.baseCombinators
    ++ base.herdrCombinators "omp"
    ++ (with jail.combinators; [
      (readwrite (noescape "~/.omp"))
      (readwrite (noescape "~/.local/share/omp"))
      (readwrite (noescape "~/.local/state/omp"))
      (readwrite (noescape "~/.cache/omp"))
      (set-env "XDG_DATA_HOME" (noescape "~/.local/share"))
      (set-env "XDG_STATE_HOME" (noescape "~/.local/state"))
      (set-env "XDG_CACHE_HOME" (noescape "~/.cache"))
    ])
  );
  jzsh = jail "jzsh" pkgs.zsh base.baseCombinators;
in
{
  home.persistence."/state".directories = [
    ".config/gh-pi"
    ".cache/omp"
    ".config/herdr"
    ".local/share/omp"
    ".local/state/omp"
  ];
  home.packages = [
    jpi
    jzsh
  ];
  programs.herdr = {
    enable = true;
    package = herdrPackage;
  };
  programs.omp = {
    enable = true;
    package = jomp;
  };

  home.file = {
    ".omp/agent/AGENTS.md".source = ./pi/AGENTS.md;
    ".omp/agent/extensions/herdr-omp-agent-state.ts".source =
      "${herdrPackage}/share/herdr/integrations/omp/herdr-agent-state.ts";
    ".omp/agent/prompts/nixpkgs-review.md".source = ./pi/prompts/nixpkgs-review.md;

    ".pi/agent/extensions/herdr-agent-state.ts".source =
      "${herdrPackage}/share/herdr/integrations/pi/herdr-agent-state.ts";
    ".pi/agent/extensions/current-model.ts".text = ''
      import type { ExtensionAPI, ExtensionContext } from "@earendil-works/pi-coding-agent";
      import { Type } from "typebox";

      function currentModelDetails(ctx: ExtensionContext) {
        const model = ctx.model;
        const thinkingLevel = ctx.getThinkingLevel?.();

        if (!model) {
          return {
            available: false,
            shortDescription: "none/none",
            longDescription: "No model is currently selected for this pi session.",
          };
        }

        const shortDescription = `''${model.name}/''${model.provider}`;
        const longDescription = [
          `Provider: ''${model.provider}`,
          `Model id: ''${model.id}`,
          `Display name: ''${model.name}`,
          `API: ''${model.api}`,
          `Base URL: ''${model.baseUrl}`,
          `Reasoning supported: ''${model.reasoning}`,
          `Input modes: ''${model.input.join(", ")}`,
          `Context window: ''${model.contextWindow}`,
          `Max output tokens: ''${model.maxTokens}`,
          `Thinking level: ''${thinkingLevel ?? "unknown"}`,
        ].join("\n");

        return {
          available: true,
          provider: model.provider,
          id: model.id,
          name: model.name,
          api: model.api,
          baseUrl: model.baseUrl,
          reasoning: model.reasoning,
          input: model.input,
          contextWindow: model.contextWindow,
          maxTokens: model.maxTokens,
          thinkingLevel,
          shortDescription,
          longDescription,
        };
      }

      export default function (pi: ExtensionAPI) {
        pi.registerTool({
          name: "current_model",
          label: "Current Model",
          description: "Return exact model currently selected for this pi session.",
          promptSnippet: "Return exact current pi session model identity.",
          promptGuidelines: [
            "Use current_model when the user asks what model you are, which model is active, or any question about exact current pi session model identity.",
          ],
          parameters: Type.Object({}),
          async execute(_toolCallId, _params, _signal, _onUpdate, ctx) {
            const details = currentModelDetails(ctx);
            return {
              content: [
                {
                  type: "text",
                  text: `''${details.shortDescription}\n\n''${details.longDescription}`,
                },
              ],
              details,
            };
          },
        });
      }
    '';

    # TODO: add notice saying to never write human output for me(paper/blog post)
    ".pi/agent/AGENTS.md".source = ./pi/AGENTS.md;

    ".pi/agent/prompts/nixpkgs-review.md".source = ./pi/prompts/nixpkgs-review.md;
  };
}
