/*
 * Create the system calls that the client can use to ask
 * for changes in the World state (using the System contracts).
 */

import { getComponentValue } from "@latticexyz/recs";
import { ClientComponents } from "./createClientComponents";
import { SetupNetworkResult } from "./setupNetwork";
import { singletonEntity } from "@latticexyz/store-sync/recs";

export type SystemCalls = ReturnType<typeof createSystemCalls>;

export function createSystemCalls(
  /*
   * The parameter list informs TypeScript that:
   *
   * - The first parameter is expected to be a
   *   SetupNetworkResult, as defined in setupNetwork.ts
   *
   *   Out of this parameter, we only care about two fields:
   *   - worldContract (which comes from getContract, see
   *     https://github.com/latticexyz/mud/blob/main/templates/vanilla/packages/client/src/mud/setupNetwork.ts#L63-L69).
   *
   *   - waitForTransaction (which comes from syncToRecs, see
   *     https://github.com/latticexyz/mud/blob/main/templates/vanilla/packages/client/src/mud/setupNetwork.ts#L77-L83).
  */
  { worldContract, waitForTransaction }: SetupNetworkResult,
  { Output }: ClientComponents
) {
  const initData = async () => {
    const tx = await worldContract.write.initData();
    await waitForTransaction(tx);
  };

  const describe = async () => {
      const tx = await worldContract.write.describe();
      await waitForTransaction(tx);
  };

  const processCommand = async (command) => {
    const tx = await worldContract.write.meat_MeatPuppetSystem_processCommandTokens([command]);
    await waitForTransaction(tx);
  };

  return {
    processCommand,
    initData,
    describe,
  };
}
