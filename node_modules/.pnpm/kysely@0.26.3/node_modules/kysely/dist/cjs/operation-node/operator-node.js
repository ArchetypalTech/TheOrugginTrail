"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.isJSONOperator = exports.isArithmeticOperator = exports.isComparisonOperator = exports.isBinaryOperator = exports.isOperator = exports.OperatorNode = exports.OPERATORS = exports.UNARY_OPERATORS = exports.UNARY_FILTER_OPERATORS = exports.BINARY_OPERATORS = exports.JSON_OPERATORS = exports.ARITHMETIC_OPERATORS = exports.COMPARISON_OPERATORS = void 0;
const object_utils_js_1 = require("../util/object-utils.js");
exports.COMPARISON_OPERATORS = [
    '=',
    '==',
    '!=',
    '<>',
    '>',
    '>=',
    '<',
    '<=',
    'in',
    'not in',
    'is',
    'is not',
    'like',
    'not like',
    'match',
    'ilike',
    'not ilike',
    '@>',
    '<@',
    '&&',
    '?',
    '?&',
    '!<',
    '!>',
    '<=>',
    '!~',
    '~',
    '~*',
    '!~*',
    '@@',
    '@@@',
    '!!',
    '<->',
    'regexp',
];
exports.ARITHMETIC_OPERATORS = [
    '+',
    '-',
    '*',
    '/',
    '%',
    '^',
    '&',
    '|',
    '#',
    '<<',
    '>>',
];
exports.JSON_OPERATORS = ['->', '->>'];
exports.BINARY_OPERATORS = [
    ...exports.COMPARISON_OPERATORS,
    ...exports.ARITHMETIC_OPERATORS,
    '&&',
    '||',
];
exports.UNARY_FILTER_OPERATORS = ['exists', 'not exists'];
exports.UNARY_OPERATORS = ['not', '-', ...exports.UNARY_FILTER_OPERATORS];
exports.OPERATORS = [
    ...exports.BINARY_OPERATORS,
    ...exports.JSON_OPERATORS,
    ...exports.UNARY_OPERATORS,
    'between',
    'between symmetric',
];
/**
 * @internal
 */
exports.OperatorNode = (0, object_utils_js_1.freeze)({
    is(node) {
        return node.kind === 'OperatorNode';
    },
    create(operator) {
        return (0, object_utils_js_1.freeze)({
            kind: 'OperatorNode',
            operator,
        });
    },
});
function isOperator(op) {
    return (0, object_utils_js_1.isString)(op) && exports.OPERATORS.includes(op);
}
exports.isOperator = isOperator;
function isBinaryOperator(op) {
    return (0, object_utils_js_1.isString)(op) && exports.BINARY_OPERATORS.includes(op);
}
exports.isBinaryOperator = isBinaryOperator;
function isComparisonOperator(op) {
    return (0, object_utils_js_1.isString)(op) && exports.COMPARISON_OPERATORS.includes(op);
}
exports.isComparisonOperator = isComparisonOperator;
function isArithmeticOperator(op) {
    return (0, object_utils_js_1.isString)(op) && exports.ARITHMETIC_OPERATORS.includes(op);
}
exports.isArithmeticOperator = isArithmeticOperator;
function isJSONOperator(op) {
    return (0, object_utils_js_1.isString)(op) && exports.JSON_OPERATORS.includes(op);
}
exports.isJSONOperator = isJSONOperator;
