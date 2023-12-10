"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.ParseJSONResultsPlugin = void 0;
const object_utils_js_1 = require("../../util/object-utils.js");
/**
 * Parses JSON strings in query results into JSON objects.
 *
 * This plugin can be useful with dialects that don't automatically parse
 * JSON into objects and arrays but return JSON strings instead.
 *
 * ```ts
 * const db = new Kysely<DB>({
 *   ...
 *   plugins: [new ParseJSONResultsPlugin()]
 * })
 * ```
 */
class ParseJSONResultsPlugin {
    // noop
    transformQuery(args) {
        return args.node;
    }
    async transformResult(args) {
        return {
            ...args.result,
            rows: parseArray(args.result.rows),
        };
    }
}
exports.ParseJSONResultsPlugin = ParseJSONResultsPlugin;
function parseArray(arr) {
    for (let i = 0; i < arr.length; ++i) {
        arr[i] = parse(arr[i]);
    }
    return arr;
}
function parse(obj) {
    if ((0, object_utils_js_1.isString)(obj)) {
        return parseString(obj);
    }
    if (Array.isArray(obj)) {
        return parseArray(obj);
    }
    if ((0, object_utils_js_1.isPlainObject)(obj)) {
        return parseObject(obj);
    }
    return obj;
}
function parseString(str) {
    if (maybeJson(str)) {
        try {
            return parse(JSON.parse(str));
        }
        catch (err) {
            // this catch block is intentionally empty.
        }
    }
    return str;
}
function maybeJson(value) {
    return value.match(/^[\[\{]/) != null;
}
function parseObject(obj) {
    for (const key in obj) {
        obj[key] = parse(obj[key]);
    }
    return obj;
}
