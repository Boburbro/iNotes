use crate::{
    models::{NewUser, User},
    utils::save_image_to_disk,
};
use r2d2::PooledConnection;
use r2d2_sqlite::SqliteConnectionManager;
use rusqlite::{self, params};

pub fn get_me(
    conn: &PooledConnection<SqliteConnectionManager>,
    user_id: u32,
) -> Result<User, rusqlite::Error> {
    let mut stmt = conn.prepare("SELECT * FROM users WHERE id = ?1")?;

    stmt.query_row([user_id], |row| {
        Ok(User {
            id: row.get("id")?,
            username: row.get("username")?,
            email: row.get("email")?,
            avatar: row.get("avatar")?,
        })
    })
}

pub fn update_profile_picture(
    conn: &PooledConnection<SqliteConnectionManager>,
    new_user: NewUser,
) -> Result<User, rusqlite::Error> {
    let result = save_image_to_disk(&new_user.avatar.unwrap()).ok();
    let avatar = result.unwrap();

    conn.execute(
        "UPDATE users SET avatar = ?1 WHERE id = ?2",
        params![avatar, new_user.id],
    )?;

    let updated_user = conn.query_row(
        "SELECT id, username, email, avatar FROM users WHERE id = ?1",
        params![new_user.id],
        |row| {
            Ok(User {
                id: row.get(0)?,
                username: row.get(1)?,
                email: row.get(2)?,
                avatar: row.get(3)?,
            })
        },
    )?;

    Ok(updated_user)
}
