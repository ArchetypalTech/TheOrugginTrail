/// <reference types="./update-set-parser.d.ts" />
import { ColumnNode } from '../operation-node/column-node.js';
import { ColumnUpdateNode } from '../operation-node/column-update-node.js';
import { expressionBuilder, } from '../expression/expression-builder.js';
import { isFunction } from '../util/object-utils.js';
import { parseValueExpression } from './value-parser.js';
export function parseUpdateExpression(update) {
    const updateObj = isFunction(update) ? update(expressionBuilder()) : update;
    return Object.entries(updateObj)
        .filter(([_, value]) => value !== undefined)
        .map(([key, value]) => {
        return ColumnUpdateNode.create(ColumnNode.create(key), parseValueExpression(value));
    });
}
