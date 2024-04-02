import { setup } from "./mud/setup";
import mudConfig from "contracts/mud.config";
import './lit-term';

const {
  components,
  systemCalls: { initData, processCommand },
  network,
} = await setup();

var playerId = 0;

components.Output.update$.subscribe((update) => {
  const [nextValue, prevValue] = update.value;
  if (nextValue.playerId == playerId) {
    console.log("Output updated", update, { nextValue, prevValue });
        // var term = $.terminal.active();
        // term.echo(nextValue.text);
    }
});

// https://vitejs.dev/guide/env-and-mode.html
if (import.meta.env.DEV) {
  const { mount: mountDevTools } = await import("@latticexyz/dev-tools");
  mountDevTools({
    config: mudConfig,
    publicClient: network.publicClient,
    walletClient: network.walletClient,
    latestBlock$: network.latestBlock$,
    storedBlockLogs$: network.storedBlockLogs$,
    worldAddress: network.worldContract.address,
    worldAbi: network.worldContract.abi,
    write$: network.write$,
    recsWorld: network.world,
  });
}
