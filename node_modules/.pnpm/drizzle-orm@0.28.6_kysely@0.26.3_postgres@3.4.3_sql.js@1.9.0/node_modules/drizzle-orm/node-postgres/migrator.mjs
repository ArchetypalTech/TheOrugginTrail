import { readMigrationFiles } from '../migrator.mjs';
import 'node:crypto';
import 'node:fs';
import 'node:path';

async function migrate(db, config) {
    const migrations = readMigrationFiles(config);
    await db.dialect.migrate(migrations, db.session);
}

export { migrate };
//# sourceMappingURL=migrator.mjs.map
