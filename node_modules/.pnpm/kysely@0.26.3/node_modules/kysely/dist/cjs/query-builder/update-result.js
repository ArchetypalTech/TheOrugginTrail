"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.UpdateResult = void 0;
class UpdateResult {
    numUpdatedRows;
    numChangedRows;
    constructor(numUpdatedRows, numChangedRows) {
        this.numUpdatedRows = numUpdatedRows;
        this.numChangedRows = numChangedRows;
    }
}
exports.UpdateResult = UpdateResult;
