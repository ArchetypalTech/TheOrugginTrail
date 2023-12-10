/// <reference types="./query-node.d.ts" />
import { InsertQueryNode } from './insert-query-node.js';
import { SelectQueryNode } from './select-query-node.js';
import { UpdateQueryNode } from './update-query-node.js';
import { DeleteQueryNode } from './delete-query-node.js';
import { WhereNode } from './where-node.js';
import { freeze } from '../util/object-utils.js';
import { ReturningNode } from './returning-node.js';
import { ExplainNode } from './explain-node.js';
/**
 * @internal
 */
export const QueryNode = freeze({
    is(node) {
        return (SelectQueryNode.is(node) ||
            InsertQueryNode.is(node) ||
            UpdateQueryNode.is(node) ||
            DeleteQueryNode.is(node));
    },
    cloneWithWhere(node, operation) {
        return freeze({
            ...node,
            where: node.where
                ? WhereNode.cloneWithOperation(node.where, 'And', operation)
                : WhereNode.create(operation),
        });
    },
    cloneWithJoin(node, join) {
        return freeze({
            ...node,
            joins: node.joins ? freeze([...node.joins, join]) : freeze([join]),
        });
    },
    cloneWithReturning(node, selections) {
        return freeze({
            ...node,
            returning: node.returning
                ? ReturningNode.cloneWithSelections(node.returning, selections)
                : ReturningNode.create(selections),
        });
    },
    cloneWithoutWhere(node) {
        return freeze({
            ...node,
            where: undefined,
        });
    },
    cloneWithExplain(node, format, options) {
        return freeze({
            ...node,
            explain: ExplainNode.create(format, options?.toOperationNode()),
        });
    },
});
