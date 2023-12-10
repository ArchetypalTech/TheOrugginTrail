"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.moonbeamDev = void 0;
const chain_js_1 = require("../../utils/chain.js");
exports.moonbeamDev = (0, chain_js_1.defineChain)({
    id: 1281,
    name: 'Moonbeam Development Node',
    network: 'development',
    nativeCurrency: {
        decimals: 18,
        name: 'DEV',
        symbol: 'DEV',
    },
    rpcUrls: {
        default: {
            http: ['http://127.0.0.1:9944'],
            webSocket: ['wss://127.0.0.1:9944'],
        },
        public: {
            http: ['http://127.0.0.1:9944'],
            webSocket: ['wss://127.0.0.1:9944'],
        },
    },
});
//# sourceMappingURL=moonbeamDev.js.map