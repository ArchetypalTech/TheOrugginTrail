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
        initData();
    } else {
        await processCommand(command);
    }
    },
    { prompt: '>', name: 'TheOrugginTrail',  greetings: '# TheOrugginTrail\nAn experiment in fully onchain text adventures\n' }
);

// Components expose a stream that triggers when the component is updated.
components.CurrentRoomId.update$.subscribe((update) => {
  const [nextValue, prevValue] = update.value;
  console.log("CurrentRoomId updated", update, { nextValue, prevValue });

  var term = $.terminal.active();
  term.echo(nextValue.value);

  //document.getElementById("counter")!.innerHTML = String(nextValue?.value ?? "unset");
});

components.Room.update$.subscribe((update) => {
  const Room = components.Room
  console.log("Room updated");
//  document.getElementById("room_description")!.innerHTML = "We need to get the update text here";
});

(window as any).showDescription = async () => {
  console.log("looking for description:", await describe())
};

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
