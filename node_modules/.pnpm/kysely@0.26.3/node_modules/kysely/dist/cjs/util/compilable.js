"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.isCompilable = void 0;
const object_utils_js_1 = require("./object-utils.js");
function isCompilable(value) {
    return (0, object_utils_js_1.isObject)(value) && (0, object_utils_js_1.isFunction)(value.compile);
}
exports.isCompilable = isCompilable;
