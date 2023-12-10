"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.getContractEvents = void 0;
const getAbiItem_js_1 = require("../../utils/abi/getAbiItem.js");
const getLogs_js_1 = require("./getLogs.js");
async function getContractEvents(client, { abi, address, args, blockHash, eventName, fromBlock, toBlock, strict, }) {
    const event = eventName
        ? (0, getAbiItem_js_1.getAbiItem)({ abi, name: eventName })
        : undefined;
    const events = !event
        ? abi.filter((x) => x.type === 'event')
        : undefined;
    return (0, getLogs_js_1.getLogs)(client, {
        address,
        args,
        blockHash,
        event,
        events,
        fromBlock,
        toBlock,
        strict,
    });
}
exports.getContractEvents = getContractEvents;
//# sourceMappingURL=getContractEvents.js.map