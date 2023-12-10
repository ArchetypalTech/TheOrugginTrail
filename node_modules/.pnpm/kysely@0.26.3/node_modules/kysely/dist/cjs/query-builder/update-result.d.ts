export declare class UpdateResult {
    readonly numUpdatedRows: bigint;
    readonly numChangedRows?: bigint;
    constructor(numUpdatedRows: bigint, numChangedRows: bigint | undefined);
}
