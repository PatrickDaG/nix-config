{
  lib,
  pkgs,
  inputs,
  ...
}:
let
  base = import ./coding-agent-jail.nix { inherit lib pkgs inputs; };
  inherit (base) jail;
  jailed-pi = jail "jailed-pi" pkgs.llm-agents.pi (
    base.baseCombinators
    ++ (with jail.combinators; [
      (readwrite (noescape "~/.pi"))
    ])
  );
in
{
  hm =
    let
      inherit (base) jail;
      jailed-omp = jail "jailed-omp" inputs.omp.packages.x86_64-linux.omp (
        base.baseCombinators
        ++ (with jail.combinators; [
          (readwrite (noescape "~/.omp"))
        ])
      );
    in
    {
      home.persistence."/state".directories = [ ".config/gh-pi" ];
      home.packages = [ jailed-pi ];
      programs.omp = {
        enable = true;
        package = jailed-omp;
        settings = {
        };
      };

      home.file = {
        ".omp/agent/AGENTS.md".source = ./pi/AGENTS.md;
        ".omp/agent/prompts/nixpkgs-review.md".source = ./pi/prompts/nixpkgs-review.md;

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
    };
}
