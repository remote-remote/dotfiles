import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

/**
 * Muscle-memory aliases for pi's builtin commands. Registering them as real
 * commands means the input layer matches them before sending to the model, so a
 * reflexive /exit or /clear on an idle session can't fire a zero-value request
 * (and its cache write) at the provider.
 */
export default function (pi: ExtensionAPI) {
  pi.registerCommand("exit", {
    description: "Alias for /quit",
    handler: async (_args, ctx) => {
      ctx.shutdown();
    },
  });

  pi.registerCommand("clear", {
    description: "Alias for /new",
    handler: async (_args, ctx) => {
      await ctx.newSession();
    },
  });
}
