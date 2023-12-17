import { setup } from "./mud/setup";
import mudConfig from "contracts/mud.config";

const {
  components,
  systemCalls: { initData, processCommand },
  network,
} = await setup();


$('body').terminal(async function(command)  {
    // sanity test for calling the contract
    if(command == 'init') {
        await initData();
} else {
    const tk = components.tokenise(command);
    await processCommand(tk);
}
    },
    { prompt: '>', name: 'TheOrugginTrail',  greetings: '# TheOrugginTrail\nAn experiment in fully onchain text adventures\n' }
);

components.Output.update$.subscribe((update) => {
  const [nextValue, prevValue] = update.value;
  console.log("Output updated", update, { nextValue, prevValue });
    var term = $.terminal.active();
    term.echo(nextValue.value);
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
