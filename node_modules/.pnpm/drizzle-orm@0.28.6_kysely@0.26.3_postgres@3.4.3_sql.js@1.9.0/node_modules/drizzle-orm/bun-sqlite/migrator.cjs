'use strict';

var migrator = require('../migrator.cjs');
require('node:crypto');
require('node:fs');
require('node:path');

function migrate(db, config) {
    const migrations = migrator.readMigrationFiles(config);
    db.dialect.migrate(migrations, db.session);
}

exports.migrate = migrate;
//# sourceMappingURL=migrator.cjs.map
