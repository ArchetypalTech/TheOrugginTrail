/// <reference types="./update-query-builder.d.ts" />
import { parseJoin, } from '../parser/join-parser.js';
import { parseTableExpressionOrList, } from '../parser/table-parser.js';
import { parseSelectArg, parseSelectAll, } from '../parser/select-parser.js';
import { QueryNode } from '../operation-node/query-node.js';
import { UpdateQueryNode } from '../operation-node/update-query-node.js';
import { parseUpdateExpression, } from '../parser/update-set-parser.js';
import { preventAwait } from '../util/prevent-await.js';
import { freeze } from '../util/object-utils.js';
import { UpdateResult } from './update-result.js';
import { isNoResultErrorConstructor, NoResultError, } from './no-result-error.js';
import { parseReferentialBinaryOperation, parseValueBinaryOperationOrExpression, } from '../parser/binary-operation-parser.js';
export class UpdateQueryBuilder {
    #props;
    constructor(props) {
        this.#props = freeze(props);
    }
    where(...args) {
        return new UpdateQueryBuilder({
            ...this.#props,
            queryNode: QueryNode.cloneWithWhere(this.#props.queryNode, parseValueBinaryOperationOrExpression(args)),
        });
    }
    whereRef(lhs, op, rhs) {
        return new UpdateQueryBuilder({
            ...this.#props,
            queryNode: QueryNode.cloneWithWhere(this.#props.queryNode, parseReferentialBinaryOperation(lhs, op, rhs)),
        });
    }
    clearWhere() {
        return new UpdateQueryBuilder({
            ...this.#props,
            queryNode: QueryNode.cloneWithoutWhere(this.#props.queryNode),
        });
    }
    from(from) {
        return new UpdateQueryBuilder({
            ...this.#props,
            queryNode: UpdateQueryNode.cloneWithFromItems(this.#props.queryNode, parseTableExpressionOrList(from)),
        });
    }
    innerJoin(...args) {
        return new UpdateQueryBuilder({
            ...this.#props,
            queryNode: QueryNode.cloneWithJoin(this.#props.queryNode, parseJoin('InnerJoin', args)),
        });
    }
    leftJoin(...args) {
        return new UpdateQueryBuilder({
            ...this.#props,
            queryNode: QueryNode.cloneWithJoin(this.#props.queryNode, parseJoin('LeftJoin', args)),
        });
    }
    rightJoin(...args) {
        return new UpdateQueryBuilder({
            ...this.#props,
            queryNode: QueryNode.cloneWithJoin(this.#props.queryNode, parseJoin('RightJoin', args)),
        });
    }
    fullJoin(...args) {
        return new UpdateQueryBuilder({
            ...this.#props,
            queryNode: QueryNode.cloneWithJoin(this.#props.queryNode, parseJoin('FullJoin', args)),
        });
    }
    set(update) {
        return new UpdateQueryBuilder({
            ...this.#props,
            queryNode: UpdateQueryNode.cloneWithUpdates(this.#props.queryNode, parseUpdateExpression(update)),
        });
    }
    returning(selection) {
        return new UpdateQueryBuilder({
            ...this.#props,
            queryNode: QueryNode.cloneWithReturning(this.#props.queryNode, parseSelectArg(selection)),
        });
    }
    returningAll() {
        return new UpdateQueryBuilder({
            ...this.#props,
            queryNode: QueryNode.cloneWithReturning(this.#props.queryNode, parseSelectAll()),
        });
    }
    /**
     * Simply calls the provided function passing `this` as the only argument. `$call` returns
     * what the provided function returns.
     *
     * If you want to conditionally call a method on `this`, see
     * the {@link $if} method.
     *
     * ### Examples
     *
     * The next example uses a helper function `log` to log a query:
     *
     * ```ts
     * function log<T extends Compilable>(qb: T): T {
     *   console.log(qb.compile())
     *   return qb
     * }
     *
     * db.updateTable('person')
     *   .set(values)
     *   .$call(log)
     *   .execute()
     * ```
     */
    $call(func) {
        return func(this);
    }
    /**
     * Call `func(this)` if `condition` is true.
     *
     * This method is especially handy with optional selects. Any `returning` or `returningAll`
     * method calls add columns as optional fields to the output type when called inside
     * the `func` callback. This is because we can't know if those selections were actually
     * made before running the code.
     *
     * You can also call any other methods inside the callback.
     *
     * ### Examples
     *
     * ```ts
     * async function updatePerson(id: number, updates: UpdateablePerson, returnLastName: boolean) {
     *   return await db
     *     .updateTable('person')
     *     .set(updates)
     *     .where('id', '=', id)
     *     .returning(['id', 'first_name'])
     *     .$if(returnLastName, (qb) => qb.returning('last_name'))
     *     .executeTakeFirstOrThrow()
     * }
     * ```
     *
     * Any selections added inside the `if` callback will be added as optional fields to the
     * output type since we can't know if the selections were actually made before running
     * the code. In the example above the return type of the `updatePerson` function is:
     *
     * ```ts
     * {
     *   id: number
     *   first_name: string
     *   last_name?: string
     * }
     * ```
     */
    $if(condition, func) {
        if (condition) {
            return func(this);
        }
        return new UpdateQueryBuilder({
            ...this.#props,
        });
    }
    /**
     * Change the output type of the query.
     *
     * You should only use this method as the last resort if the types
     * don't support your use case.
     */
    $castTo() {
        return new UpdateQueryBuilder(this.#props);
    }
    /**
     * Narrows (parts of) the output type of the query.
     *
     * Kysely tries to be as type-safe as possible, but in some cases we have to make
     * compromises for better maintainability and compilation performance. At present,
     * Kysely doesn't narrow the output type of the query based on {@link set} input
     * when using {@link where} and/or {@link returning} or {@link returningAll}.
     *
     * This utility method is very useful for these situations, as it removes unncessary
     * runtime assertion/guard code. Its input type is limited to the output type
     * of the query, so you can't add a column that doesn't exist, or change a column's
     * type to something that doesn't exist in its union type.
     *
     * ### Examples
     *
     * Turn this code:
     *
     * ```ts
     * const person = await db.updateTable('person')
     *   .set({ deletedAt: now })
     *   .where('id', '=', id)
     *   .where('nullable_column', 'is not', null)
     *   .returningAll()
     *   .executeTakeFirstOrThrow()
     *
     * if (person.nullable_column) {
     *   functionThatExpectsPersonWithNonNullValue(person)
     * }
     * ```
     *
     * Into this:
     *
     * ```ts
     * const person = await db.updateTable('person')
     *   .set({ deletedAt: now })
     *   .where('id', '=', id)
     *   .where('nullable_column', 'is not', null)
     *   .returningAll()
     *   .$narrowType<{ deletedAt: Date; nullable_column: string }>()
     *   .executeTakeFirstOrThrow()
     *
     * functionThatExpectsPersonWithNonNullValue(person)
     * ```
     */
    $narrowType() {
        return new UpdateQueryBuilder(this.#props);
    }
    /**
     * Asserts that query's output row type equals the given type `T`.
     *
     * This method can be used to simplify excessively complex types to make typescript happy
     * and much faster.
     *
     * Kysely uses complex type magic to achieve its type safety. This complexity is sometimes too much
     * for typescript and you get errors like this:
     *
     * ```
     * error TS2589: Type instantiation is excessively deep and possibly infinite.
     * ```
     *
     * In these case you can often use this method to help typescript a little bit. When you use this
     * method to assert the output type of a query, Kysely can drop the complex output type that
     * consists of multiple nested helper types and replace it with the simple asserted type.
     *
     * Using this method doesn't reduce type safety at all. You have to pass in a type that is
     * structurally equal to the current type.
     *
     * ### Examples
     *
     * ```ts
     * const result = await db
     *   .with('updated_person', (qb) => qb
     *     .updateTable('person')
     *     .set(person)
     *     .where('id', '=', person.id)
     *     .returning('first_name')
     *     .$assertType<{ first_name: string }>()
     *   )
     *   .with('updated_pet', (qb) => qb
     *     .updateTable('pet')
     *     .set(pet)
     *     .where('owner_id', '=', person.id)
     *     .returning(['name as pet_name', 'species'])
     *     .$assertType<{ pet_name: string, species: Species }>()
     *   )
     *   .selectFrom(['updated_person', 'updated_pet'])
     *   .selectAll()
     *   .executeTakeFirstOrThrow()
     * ```
     */
    $assertType() {
        return new UpdateQueryBuilder(this.#props);
    }
    /**
     * Returns a copy of this UpdateQueryBuilder instance with the given plugin installed.
     */
    withPlugin(plugin) {
        return new UpdateQueryBuilder({
            ...this.#props,
            executor: this.#props.executor.withPlugin(plugin),
        });
    }
    toOperationNode() {
        return this.#props.executor.transformQuery(this.#props.queryNode, this.#props.queryId);
    }
    compile() {
        return this.#props.executor.compileQuery(this.toOperationNode(), this.#props.queryId);
    }
    /**
     * Executes the query and returns an array of rows.
     *
     * Also see the {@link executeTakeFirst} and {@link executeTakeFirstOrThrow} methods.
     */
    async execute() {
        const compiledQuery = this.compile();
        const query = compiledQuery.query;
        const result = await this.#props.executor.executeQuery(compiledQuery, this.#props.queryId);
        if (this.#props.executor.adapter.supportsReturning && query.returning) {
            return result.rows;
        }
        return [
            new UpdateResult(
            // TODO: remove numUpdatedOrDeletedRows.
            // TODO: https://github.com/kysely-org/kysely/pull/431#discussion_r1172330899
            result.numAffectedRows ?? result.numUpdatedOrDeletedRows ?? BigInt(0), result.numChangedRows),
        ];
    }
    /**
     * Executes the query and returns the first result or undefined if
     * the query returned no result.
     */
    async executeTakeFirst() {
        const [result] = await this.execute();
        return result;
    }
    /**
     * Executes the query and returns the first result or throws if
     * the query returned no result.
     *
     * By default an instance of {@link NoResultError} is thrown, but you can
     * provide a custom error class, or callback as the only argument to throw a different
     * error.
     */
    async executeTakeFirstOrThrow(errorConstructor = NoResultError) {
        const result = await this.executeTakeFirst();
        if (result === undefined) {
            const error = isNoResultErrorConstructor(errorConstructor)
                ? new errorConstructor(this.toOperationNode())
                : errorConstructor(this.toOperationNode());
            throw error;
        }
        return result;
    }
    async *stream(chunkSize = 100) {
        const compiledQuery = this.compile();
        const stream = this.#props.executor.stream(compiledQuery, chunkSize, this.#props.queryId);
        for await (const item of stream) {
            yield* item.rows;
        }
    }
    async explain(format, options) {
        const builder = new UpdateQueryBuilder({
            ...this.#props,
            queryNode: QueryNode.cloneWithExplain(this.#props.queryNode, format, options),
        });
        return await builder.execute();
    }
}
preventAwait(UpdateQueryBuilder, "don't await UpdateQueryBuilder instances directly. To execute the query you need to call `execute` or `executeTakeFirst`.");
