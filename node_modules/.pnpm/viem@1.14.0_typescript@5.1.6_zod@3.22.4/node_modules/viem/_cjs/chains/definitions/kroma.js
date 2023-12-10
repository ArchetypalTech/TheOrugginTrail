"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.kroma = void 0;
const chain_js_1 = require("../../utils/chain.js");
exports.kroma = (0, chain_js_1.defineChain)({
    id: 255,
    network: 'kroma',
    name: 'Kroma',
    nativeCurrency: { name: 'ETH', symbol: 'ETH', decimals: 18 },
    rpcUrls: {
        default: {
            http: ['https://api.kroma.network'],
        },
        public: {
            http: ['https://api.kroma.network'],
        },
    },
    blockExplorers: {
        default: {
            name: 'Kroma Explorer',
            url: 'https://blockscout.kroma.network',
        },
    },
    testnet: false,
});
//# sourceMappingURL=kroma.js.map