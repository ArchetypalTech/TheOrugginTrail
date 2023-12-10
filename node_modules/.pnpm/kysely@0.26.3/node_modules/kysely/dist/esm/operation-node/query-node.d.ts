import { InsertQueryNode } from './insert-query-node.js';
import { SelectQueryNode } from './select-query-node.js';
import { UpdateQueryNode } from './update-query-node.js';
import { DeleteQueryNode } from './delete-query-node.js';
import { WhereNode } from './where-node.js';
import { JoinNode } from './join-node.js';
import { SelectionNode } from './selection-node.js';
import { ReturningNode } from './returning-node.js';
import { OperationNode } from './operation-node.js';
import { ExplainNode } from './explain-node.js';
import { ExplainFormat } from '../util/explainable.js';
import { Expression } from '../expression/expression.js';
export type QueryNode = SelectQueryNode | InsertQueryNode | UpdateQueryNode | DeleteQueryNode;
type HasJoins = {
    joins?: ReadonlyArray<JoinNode>;
};
type HasWhere = {
    where?: WhereNode;
};
type HasReturning = {
    returning?: ReturningNode;
};
type HasExplain = {
    explain?: ExplainNode;
};
/**
 * @internal
 */
export declare const QueryNode: Readonly<{
    is(node: OperationNode): node is QueryNode;
    cloneWithWhere<T extends HasWhere>(node: T, operation: OperationNode): T;
    cloneWithJoin<T_1 extends HasJoins>(node: T_1, join: JoinNode): T_1;
    cloneWithReturning<T_2 extends HasReturning>(node: T_2, selections: ReadonlyArray<SelectionNode>): T_2;
    cloneWithoutWhere<T_3 extends HasWhere>(node: T_3): T_3;
    cloneWithExplain<T_4 extends HasExplain>(node: T_4, format: ExplainFormat | undefined, options: Expression<any> | undefined): T_4;
}>;
export {};
