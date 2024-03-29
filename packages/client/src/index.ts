import { setup } from "./mud/setup";
import mudConfig from "contracts/mud.config";

import './lit-term';

const {
  components,
  systemCalls: { initData, processCommand },
  network,
} = await setup();


var playerId = 0;

// $('body').terminal(async function(command)  {
//     var term = $.terminal.active();
//
//     if(command == 'be bob') {
//         playerId = 1;
//         term.echo('Set to bob');
//     } else if(command == 'be steve') {
//         playerId = 2;
//         term.echo('Set to steve');
//     } else if(command == 'be nigel') {
//         playerId = 3;
//         term.echo('Set to nigel');
//     } else if(command == 'init') {
//         await initData();
//     } else {
//         const tk = components.tokenise(command);
//         await processCommand(tk,playerId);
//     }
//     },
//     { prompt: '>', name: 'TheOrugginTrail',  greetings: '# TheOrugginTrail\nAn experiment in fully onchain text adventures\n' }
// );

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
