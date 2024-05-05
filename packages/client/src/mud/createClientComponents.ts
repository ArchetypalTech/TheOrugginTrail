/*
 * Creates components for use by the client.
 *
 * By default it returns the components from setupNetwork.ts, those which are
 * automatically inferred from the mud.config.ts table definitions.
 *
 * However, you can add or override components here as needed. This
 * lets you add user defined components, which may or may not have
 * an onchain component.
 */

import { SetupNetworkResult } from "./setupNetwork";

export type ClientComponents = ReturnType<typeof createClientComponents>;

export function createClientComponents({ components }: SetupNetworkResult) {

    // we only handle for 16 word inputs and we further
    // only handle for verbs, objects with names <16
    function tokenise(input: string): string[] {
        const tokens = input.split(/\s+/);
        return tokens
          .filter(token => token.length <= 16)
          .map(token => token.toUpperCase());
    }

    return {
        ...components,
        tokenise,
        // add your client components or overrides here
    };
}
