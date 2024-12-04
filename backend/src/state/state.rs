use r2d2::{Pool, PooledConnection};
use r2d2_sqlite::SqliteConnectionManager;
use rusqlite::Error;

pub struct AppState {
    pub pool: Pool<SqliteConnectionManager>,
}

impl AppState {
    pub fn get_conn_with_foreign_keys(
        &self,
    ) -> Result<PooledConnection<SqliteConnectionManager>, Error> {
        let conn: r2d2::PooledConnection<SqliteConnectionManager> = self.pool.get().unwrap();
        conn.execute("PRAGMA foreign_keys = ON;", []).unwrap();
        Ok(conn)
    }
}
