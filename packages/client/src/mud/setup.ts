/*
 * This file sets up all the definitions required for a MUD client.
 */

import { createClientComponents } from "./createClientComponents";
import { createSystemCalls } from "./createSystemCalls";
import { setupNetwork } from "./setupNetwork";
import { privateState } from "../gribi/state";
import { setup as setupProver } from "@gribi/evm-rootsystem"
export type SetupResult = Awaited<ReturnType<typeof setup>>;


export async function setup() {
  const network = await setupNetwork();
  const components = createClientComponents(network);
  const systemCalls = createSystemCalls(network, components);

  setupProver();

  return {
    privateState,
    network,
    components,
    systemCalls,
  };
}
