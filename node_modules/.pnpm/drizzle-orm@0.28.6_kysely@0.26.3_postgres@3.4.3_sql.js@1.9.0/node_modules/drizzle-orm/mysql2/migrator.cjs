'use strict';

var migrator = require('../migrator.cjs');
require('node:crypto');
require('node:fs');
require('node:path');

async function migrate(db, config) {
    const migrations = migrator.readMigrationFiles(config);
    await db.dialect.migrate(migrations, db.session, config);
}

exports.migrate = migrate;
//# sourceMappingURL=migrator.cjs.map
