/// <reference types="./update-result.d.ts" />
export class UpdateResult {
    numUpdatedRows;
    numChangedRows;
    constructor(numUpdatedRows, numChangedRows) {
        this.numUpdatedRows = numUpdatedRows;
        this.numChangedRows = numChangedRows;
    }
}
