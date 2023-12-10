"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.isAliasedExpression = exports.isExpression = void 0;
const operation_node_source_js_1 = require("../operation-node/operation-node-source.js");
const object_utils_js_1 = require("../util/object-utils.js");
function isExpression(obj) {
    return (0, object_utils_js_1.isObject)(obj) && 'expressionType' in obj && (0, operation_node_source_js_1.isOperationNodeSource)(obj);
}
exports.isExpression = isExpression;
function isAliasedExpression(obj) {
    return ((0, object_utils_js_1.isObject)(obj) &&
        'expression' in obj &&
        (0, object_utils_js_1.isString)(obj.alias) &&
        (0, operation_node_source_js_1.isOperationNodeSource)(obj));
}
exports.isAliasedExpression = isAliasedExpression;
