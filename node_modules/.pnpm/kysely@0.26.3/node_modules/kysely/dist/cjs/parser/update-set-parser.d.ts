import { ColumnUpdateNode } from '../operation-node/column-update-node.js';
import { ExpressionBuilder } from '../expression/expression-builder.js';
import { UpdateKeys, UpdateType } from '../util/column-type.js';
import { ValueExpression } from './value-parser.js';
export type UpdateObject<DB, TB extends keyof DB, UT extends keyof DB = TB> = {
    [C in UpdateKeys<DB[UT]>]?: ValueExpression<DB, TB, UpdateType<DB[UT][C]>> | undefined;
};
export type UpdateObjectFactory<DB, TB extends keyof DB, UT extends keyof DB> = (eb: ExpressionBuilder<DB, TB>) => UpdateObject<DB, TB, UT>;
export type UpdateExpression<DB, TB extends keyof DB, UT extends keyof DB = TB> = UpdateObject<DB, TB, UT> | UpdateObjectFactory<DB, TB, UT>;
export declare function parseUpdateExpression(update: UpdateExpression<any, any, any>): ReadonlyArray<ColumnUpdateNode>;
