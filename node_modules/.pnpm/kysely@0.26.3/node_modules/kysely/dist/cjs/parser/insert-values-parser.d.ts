import { ColumnNode } from '../operation-node/column-node.js';
import { ValueExpression } from './value-parser.js';
import { ValuesNode } from '../operation-node/values-node.js';
import { NonNullableInsertKeys, NullableInsertKeys, InsertType } from '../util/column-type.js';
import { ExpressionBuilder } from '../expression/expression-builder.js';
export type InsertObject<DB, TB extends keyof DB> = {
    [C in NonNullableInsertKeys<DB[TB]>]: ValueExpression<DB, TB, InsertType<DB[TB][C]>>;
} & {
    [C in NullableInsertKeys<DB[TB]>]?: ValueExpression<DB, TB, InsertType<DB[TB][C]>> | undefined;
};
export type InsertObjectOrList<DB, TB extends keyof DB> = InsertObject<DB, TB> | ReadonlyArray<InsertObject<DB, TB>>;
export type InsertObjectOrListFactory<DB, TB extends keyof DB> = (eb: ExpressionBuilder<DB, TB>) => InsertObjectOrList<DB, TB>;
export type InsertExpression<DB, TB extends keyof DB> = InsertObjectOrList<DB, TB> | InsertObjectOrListFactory<DB, TB>;
export declare function parseInsertExpression(arg: InsertExpression<any, any>): [ReadonlyArray<ColumnNode>, ValuesNode];
