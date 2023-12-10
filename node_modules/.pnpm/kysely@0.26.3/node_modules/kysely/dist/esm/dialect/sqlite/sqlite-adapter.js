/// <reference types="./sqlite-adapter.d.ts" />
export class SqliteAdapter {
    get supportsTransactionalDdl() {
        return false;
    }
    get supportsReturning() {
        return true;
    }
    async acquireMigrationLock(_db, _opt) {
        // SQLite only has one connection that's reserved by the migration system
        // for the whole time between acquireMigrationLock and releaseMigrationLock.
        // We don't need to do anything here.
    }
    async releaseMigrationLock(_db, _opt) {
        // SQLite only has one connection that's reserved by the migration system
        // for the whole time between acquireMigrationLock and releaseMigrationLock.
        // We don't need to do anything here.
    }
}
