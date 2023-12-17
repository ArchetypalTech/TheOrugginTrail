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

    function tokenise(input: string): string[] {
        // Split the input string on whitespace
        const tokens = input.split(/\s+/);

        // Filter out tokens that are longer than 16 characters
        const filteredTokens = tokens.filter(token => token.length <= 16);

        return filteredTokens;
        // Convert each character of each token to its uint8 ASCII value
        // this is almost certainly a mistake
        //const encodedTokens = filteredTokens.map(token =>
                                                 //Array.from(token).map(char => char.charCodeAt(0))
                                                //);

                                                //return encodedTokens;
    }

    return {
        ...components,
        tokenise,
        // add your client components or overrides here
    };
}
