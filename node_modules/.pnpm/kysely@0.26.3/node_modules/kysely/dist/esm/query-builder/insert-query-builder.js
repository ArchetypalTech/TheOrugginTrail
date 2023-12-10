/// <reference types="./insert-query-builder.d.ts" />
import { parseSelectArg, parseSelectAll, } from '../parser/select-parser.js';
import { parseInsertExpression, } from '../parser/insert-values-parser.js';
import { InsertQueryNode } from '../operation-node/insert-query-node.js';
import { QueryNode } from '../operation-node/query-node.js';
import { parseUpdateExpression, } from '../parser/update-set-parser.js';
import { preventAwait } from '../util/prevent-await.js';
import { freeze } from '../util/object-utils.js';
import { OnDuplicateKeyNode } from '../operation-node/on-duplicate-key-node.js';
import { InsertResult } from './insert-result.js';
import { isNoResultErrorConstructor, NoResultError, } from './no-result-error.js';
import { parseExpression, } from '../parser/expression-parser.js';
import { ColumnNode } from '../operation-node/column-node.js';
import { OnConflictBuilder, } from './on-conflict-builder.js';
import { OnConflictNode } from '../operation-node/on-conflict-node.js';
export class InsertQueryBuilder {
    #props;
    constructor(props) {
        this.#props = freeze(props);
    }
    values(insert) {
        const [columns, values] = parseInsertExpression(insert);
        return new InsertQueryBuilder({
            ...this.#props,
            queryNode: InsertQueryNode.cloneWith(this.#props.queryNode, {
                columns,
                values,
            }),
        });
    }
    /**
     * Sets the columns to insert.
     *
     * The {@link values} method sets both the columns and the values and this method
     * is not needed. But if you are using the {@link expression} method, you can use
     * this method to set the columns to insert.
     *
     * ### Examples
     *
     * ```ts
     * db.insertInto('person')
     *   .columns(['first_name'])
     *   .expression((eb) => eb.selectFrom('pet').select('pet.name'))
     * ```
     *
     * The generated SQL (PostgreSQL):
     *
     * ```sql
     * insert into "person" ("first_name")
     * select "pet"."name" from "pet"
     * ```
     */
    columns(columns) {
        return new InsertQueryBuilder({
            ...this.#props,
            queryNode: InsertQueryNode.cloneWith(this.#props.queryNode, {
                columns: freeze(columns.map(ColumnNode.create)),
            }),
        });
    }
    /**
     * Insert an arbitrary expression. For example the result of a select query.
     *
     * ### Examples
     *
     * <!-- siteExample("insert", "Insert subquery", 50) -->
     *
     * You can create an `INSERT INTO SELECT FROM` query using the `expression` method:
     *
     * ```ts
     * const result = await db.insertInto('person')
     *   .columns(['first_name', 'last_name', 'age'])
     *   .expression((eb) => eb
     *     .selectFrom('pet')
     *     .select((eb) => [
     *       'pet.name',
     *       eb.val('Petson').as('last_name'),
     *       eb.val(7).as('age'),
     *     ])
     *   )
     *   .execute()
     * ```
     *
     * The generated SQL (PostgreSQL):
     *
     * ```sql
     * insert into "person" ("first_name", "last_name", "age")
     * select "pet"."name", $1 as "first_name", $2 as "last_name" from "pet"
     * ```
     */
    expression(expression) {
        return new InsertQueryBuilder({
            ...this.#props,
            queryNode: InsertQueryNode.cloneWith(this.#props.queryNode, {
                values: parseExpression(expression),
            }),
        });
    }
    /**
     * Changes an `insert into` query to an `insert ignore into` query.
     *
     * If you use the ignore modifier, ignorable errors that occur while executing the
     * insert statement are ignored. For example, without ignore, a row that duplicates
     * an existing unique index or primary key value in the table causes a duplicate-key
     * error and the statement is aborted. With ignore, the row is discarded and no error
     * occurs.
     *
     * This is only supported on some dialects like MySQL. On most dialects you should
     * use the {@link onConflict} method.
     *
     * ### Examples
     *
     * ```ts
     * await db.insertInto('person')
     *   .ignore()
     *   .values(values)
     *   .execute()
     * ```
     */
    ignore() {
        return new InsertQueryBuilder({
            ...this.#props,
            queryNode: InsertQueryNode.cloneWith(this.#props.queryNode, {
                ignore: true,
            }),
        });
    }
    /**
     * Adds an `on conflict` clause to the query.
     *
     * `on conflict` is only supported by some dialects like PostgreSQL and SQLite. On MySQL
     * you can use {@link ignore} and {@link onDuplicateKeyUpdate} to achieve similar results.
     *
     * ### Examples
     *
     * ```ts
     * await db
     *   .insertInto('pet')
     *   .values({
     *     name: 'Catto',
     *     species: 'cat',
     *   })
     *   .onConflict((oc) => oc
     *     .column('name')
     *     .doUpdateSet({ species: 'hamster' })
     *   )
     *   .execute()
     * ```
     *
     * The generated SQL (PostgreSQL):
     *
     * ```sql
     * insert into "pet" ("name", "species")
     * values ($1, $2)
     * on conflict ("name")
     * do update set "species" = $3
     * ```
     *
     * You can provide the name of the constraint instead of a column name:
     *
     * ```ts
     * await db
     *   .insertInto('pet')
     *   .values({
     *     name: 'Catto',
     *     species: 'cat',
     *   })
     *   .onConflict((oc) => oc
     *     .constraint('pet_name_key')
     *     .doUpdateSet({ species: 'hamster' })
     *   )
     *   .execute()
     * ```
     *
     * The generated SQL (PostgreSQL):
     *
     * ```sql
     * insert into "pet" ("name", "species")
     * values ($1, $2)
     * on conflict on constraint "pet_name_key"
     * do update set "species" = $3
     * ```
     *
     * You can also specify an expression as the conflict target in case
     * the unique index is an expression index:
     *
     * ```ts
     * import { sql } from 'kysely'
     *
     * await db
     *   .insertInto('pet')
     *   .values({
     *     name: 'Catto',
     *     species: 'cat',
     *   })
     *   .onConflict((oc) => oc
     *     .expression(sql`lower(name)`)
     *     .doUpdateSet({ species: 'hamster' })
     *   )
     *   .execute()
     * ```
     *
     * The generated SQL (PostgreSQL):
     *
     * ```sql
     * insert into "pet" ("name", "species")
     * values ($1, $2)
     * on conflict (lower(name))
     * do update set "species" = $3
     * ```
     *
     * You can add a filter for the update statement like this:
     *
     * ```ts
     * await db
     *   .insertInto('pet')
     *   .values({
     *     name: 'Catto',
     *     species: 'cat',
     *   })
     *   .onConflict((oc) => oc
     *     .column('name')
     *     .doUpdateSet({ species: 'hamster' })
     *     .where('excluded.name', '!=', 'Catto'')
     *   )
     *   .execute()
     * ```
     *
     * The generated SQL (PostgreSQL):
     *
     * ```sql
     * insert into "pet" ("name", "species")
     * values ($1, $2)
     * on conflict ("name")
     * do update set "species" = $3
     * where "excluded"."name" != $4
     * ```
     *
     * You can create an `on conflict do nothing` clauses like this:
     *
     * ```ts
     * await db
     *   .insertInto('pet')
     *   .values({
     *     name: 'Catto',
     *     species: 'cat',
     *   })
     *   .onConflict((oc) => oc
     *     .column('name')
     *     .doNothing()
     *   )
     *   .execute()
     * ```
     *
     * The generated SQL (PostgreSQL):
     *
     * ```sql
     * insert into "pet" ("name", "species")
     * values ($1, $2)
     * on conflict ("name") do nothing
     * ```
     *
     * You can refer to the columns of the virtual `excluded` table
     * in a type-safe way using a callback and the `ref` method of
     * `ExpressionBuilder`:
     *
     * ```ts
     * db.insertInto('person')
     *   .values(person)
     *   .onConflict(oc => oc
     *     .column('id')
     *     .doUpdateSet({
     *       first_name: (eb) => eb.ref('excluded.first_name'),
     *       last_name: (eb) => eb.ref('excluded.last_name')
     *     })
     *   )
     * ```
     */
    onConflict(callback) {
        return new InsertQueryBuilder({
            ...this.#props,
            queryNode: InsertQueryNode.cloneWith(this.#props.queryNode, {
                onConflict: callback(new OnConflictBuilder({
                    onConflictNode: OnConflictNode.create(),
                })).toOperationNode(),
            }),
        });
    }
    /**
     * Adds `on duplicate key update` to the query.
     *
     * If you specify `on duplicate key update`, and a row is inserted that would cause
     * a duplicate value in a unique index or primary key, an update of the old row occurs.
     *
     * This is only implemented by some dialects like MySQL. On most dialects you should
     * use {@link onConflict} instead.
     *
     * ### Examples
     *
     * ```ts
     * await db
     *   .insertInto('person')
     *   .values(values)
     *   .onDuplicateKeyUpdate({ species: 'hamster' })
     * ```
     */
    onDuplicateKeyUpdate(update) {
        return new InsertQueryBuilder({
            ...this.#props,
            queryNode: InsertQueryNode.cloneWith(this.#props.queryNode, {
                onDuplicateKey: OnDuplicateKeyNode.create(parseUpdateExpression(update)),
            }),
        });
    }
    returning(selection) {
        return new InsertQueryBuilder({
            ...this.#props,
            queryNode: QueryNode.cloneWithReturning(this.#props.queryNode, parseSelectArg(selection)),
        });
    }
    returningAll() {
        return new InsertQueryBuilder({
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
     * async function insertPerson(values: InsertablePerson, returnLastName: boolean) {
     *   return await db
     *     .insertInto('person')
     *     .values(values)
     *     .returning(['id', 'first_name'])
     *     .$if(returnLastName, (qb) => qb.returning('last_name'))
     *     .executeTakeFirstOrThrow()
     * }
     * ```
     *
     * Any selections added inside the `if` callback will be added as optional fields to the
     * output type since we can't know if the selections were actually made before running
     * the code. In the example above the return type of the `insertPerson` function is:
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
        return new InsertQueryBuilder({
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
        return new InsertQueryBuilder(this.#props);
    }
    /**
     * Narrows (parts of) the output type of the query.
     *
     * Kysely tries to be as type-safe as possible, but in some cases we have to make
     * compromises for better maintainability and compilation performance. At present,
     * Kysely doesn't narrow the output type of the query based on {@link values} input
     * when using {@link returning} or {@link returningAll}.
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
     * const person = await db.insertInto('person')
     *   .values({ ...inputPerson, nullable_column: 'hell yeah!' })
     *   .returningAll()
     *   .executeTakeFirstOrThrow()
     *
     * if (nullable_column) {
     *   functionThatExpectsPersonWithNonNullValue(person)
     * }
     * ```
     *
     * Into this:
     *
     * ```ts
     * const person = await db.insertInto('person')
     *   .values({ ...inputPerson, nullable_column: 'hell yeah!' })
     *   .returningAll()
     *   .$narrowType<{ nullable_column: string }>()
     *   .executeTakeFirstOrThrow()
     *
     * functionThatExpectsPersonWithNonNullValue(person)
     * ```
     */
    $narrowType() {
        return new InsertQueryBuilder(this.#props);
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
     *   .with('new_person', (qb) => qb
     *     .insertInto('person')
     *     .values(person)
     *     .returning('id')
     *     .$assertType<{ id: string }>()
     *   )
     *   .with('new_pet', (qb) => qb
     *     .insertInto('pet')
     *     .values((eb) => ({ owner_id: eb.selectFrom('new_person').select('id'), ...pet }))
     *     .returning(['name as pet_name', 'species'])
     *     .$assertType<{ pet_name: string, species: Species }>()
     *   )
     *   .selectFrom(['new_person', 'new_pet'])
     *   .selectAll()
     *   .executeTakeFirstOrThrow()
     * ```
     */
    $assertType() {
        return new InsertQueryBuilder(this.#props);
    }
    /**
     * Returns a copy of this InsertQueryBuilder instance with the given plugin installed.
     */
    withPlugin(plugin) {
        return new InsertQueryBuilder({
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
            new InsertResult(result.insertId, 
            // TODO: remove numUpdatedOrDeletedRows.
            result.numAffectedRows ?? result.numUpdatedOrDeletedRows),
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
        const builder = new InsertQueryBuilder({
            ...this.#props,
            queryNode: QueryNode.cloneWithExplain(this.#props.queryNode, format, options),
        });
        return await builder.execute();
    }
}
preventAwait(InsertQueryBuilder, "don't await InsertQueryBuilder instances directly. To execute the query you need to call `execute` or `executeTakeFirst`.");
