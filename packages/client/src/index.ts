import { setup } from "./mud/setup";
import mudConfig from "contracts/mud.config";
import './lit-term';

const {
  components,
  systemCalls: { initData, processCommand },
  network,
} = await setup();

var playerId = 0;

// Bind the lit element via an event listener so that we can get the command string and pass it
// on to the tokeniser and then the contract code
const textInput = document.querySelector('l-terminal');
if (textInput) {
  textInput.addEventListener('command-update', (event) => {
    console.log('Input value changed to:', (event as CustomEvent).detail.value);
    const command = (event as CustomEvent).detail.value;
    const tokens = components.tokenise(command);
    runCmd(tokens);
  });
}

/*
 pass the tokens into the world, and we are done until we
 get the event from the Output contract
 this "return" is a text string built up on the contract side
 this is temporary. The contract should in fact send back an array
 of hashes that index into a locally held LUT that indexes the locations
 of compressed strings that we then decompress and assemble client side
*/
function runCmd(cmd: string[]): void {
  console.log('run cmd', cmd);
  processCommand(cmd, playerId);
}



components.Output.update$.subscribe((update) => {
  const [nextValue, prevValue] = update.value;
  if (nextValue.playerId == playerId) {
    console.log("Output updated", update, { nextValue, prevValue });
    if (textInput) {
      if (Array.isArray(textInput.history)) {
        textInput.history = [...textInput.history, nextValue];
      }
    }
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
