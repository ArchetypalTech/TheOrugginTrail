"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.isAsyncIterable = void 0;
/** @internal */
function isAsyncIterable(value) {
    return value != null && Symbol.asyncIterator in value;
}
exports.isAsyncIterable = isAsyncIterable;
//# sourceMappingURL=isAsyncIterable.js.map