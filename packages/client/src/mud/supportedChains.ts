/*
 * The supported chains.
 * By default, there are only two chains here:
 *
 * - mudFoundry, the chain running on anvil that pnpm dev
 *   starts by default. It is similar to the viem anvil chain
 *   (see https://viem.sh/docs/clients/test.html), but with the
 *   basefee set to zero to avoid transaction fees.
 * - latticeTestnet, our public test network.
 *
 */

import { MUDChain, latticeTestnet, mudFoundry } from "@latticexyz/common/chains";

/*
 * See https://mud.dev/tutorials/minimal/deploy#run-the-user-interface
 * for instructions on how to add networks.
 */

const fluentTestnet: MUDChain = {
  name: "Fluent Testnet",
  id: 1337,
  network: "fluent-testnet",
  nativeCurrency: { decimals: 18, name: "EtherDollar", symbol: "WZT" },
  rpcUrls: {
    default: {
      http: ["https://rpc.dev1.fluentlabs.xyz/"],
      webSocket: [""],
    },
    public: {
      http: ["https://rpc.dev1.fluentlabs.xyz/"],
      webSocket: [""],
    },
  },
  blockExplorers: {
    default: {
      name: "Blockscout",
      url: "https://blockscout.dev1.fluentlabs.xyz/",
    },
  },
  faucetUrl: "https://faucet.dev1.fluentlabs.xyz/",
} as const;

export const supportedChains: MUDChain[] = [mudFoundry, latticeTestnet, fluentTestnet];