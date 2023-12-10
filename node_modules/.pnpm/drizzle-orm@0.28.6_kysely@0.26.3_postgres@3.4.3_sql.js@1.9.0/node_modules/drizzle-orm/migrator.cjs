'use strict';

var crypto = require('node:crypto');
var fs = require('node:fs');
var path = require('node:path');

function readMigrationFiles(config) {
    let migrationFolderTo;
    if (typeof config === 'string') {
        const configAsString = fs.readFileSync(path.resolve('.', config), 'utf8');
        const jsonConfig = JSON.parse(configAsString);
        migrationFolderTo = jsonConfig.out;
    }
    else {
        migrationFolderTo = config.migrationsFolder;
    }
    if (!migrationFolderTo) {
        throw new Error('no migration folder defined');
    }
    const migrationQueries = [];
    const journalPath = `${migrationFolderTo}/meta/_journal.json`;
    if (!fs.existsSync(journalPath)) {
        throw new Error(`Can't find meta/_journal.json file`);
    }
    const journalAsString = fs.readFileSync(`${migrationFolderTo}/meta/_journal.json`).toString();
    const journal = JSON.parse(journalAsString);
    for (const journalEntry of journal.entries) {
        const migrationPath = `${migrationFolderTo}/${journalEntry.tag}.sql`;
        try {
            const query = fs.readFileSync(`${migrationFolderTo}/${journalEntry.tag}.sql`).toString();
            const result = query.split('--> statement-breakpoint').map((it) => {
                return it;
            });
            migrationQueries.push({
                sql: result,
                bps: journalEntry.breakpoints,
                folderMillis: journalEntry.when,
                hash: crypto.createHash('sha256').update(query).digest('hex'),
            });
        }
        catch {
            throw new Error(`No file ${migrationPath} found in ${migrationFolderTo} folder`);
        }
    }
    return migrationQueries;
}

exports.readMigrationFiles = readMigrationFiles;
//# sourceMappingURL=migrator.cjs.map
