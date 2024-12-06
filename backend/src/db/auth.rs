use crate::{errors::DatabaseError, models::User};
use rusqlite::{params, Connection, Error};

pub fn login(username: &str, password: &str, conn: &Connection) -> Result<User, DatabaseError> {
    let mut stmt = conn.prepare(
        "SELECT 
        id, avatar, email, username, password FROM users 
        WHERE username = ?1",
    )?;

    // Fetch user and password from the database
    let result: Result<(User, String), rusqlite::Error> = stmt.query_row([username], |row| {
        let user_password: String = row.get("password")?;
        Ok((
            User {
                id: row.get("id")?,
                username: row.get("username")?,
                avatar: row.get("avatar")?,
                email: row.get("email")?,
            },
            user_password,
        ))
    });

    // Process the result
    match result {
        Ok((user, user_password)) => {
            // Verify the password using bcrypt
            match bcrypt::verify(password, &user_password) {
                Ok(true) => Ok(user),
                Ok(false) => Err(DatabaseError::IncorrectCredentials),
                Err(_) => Err(DatabaseError::IncorrectCredentials),
            }
        }
        Err(Error::QueryReturnedNoRows) => Err(DatabaseError::UserNotFound),
        Err(_) => Err(DatabaseError::InternalServerError),
    }
}

pub fn register(
    email: &str,
    username: &str,
    password: &str,
    conn: &Connection,
) -> Result<User, DatabaseError> {
    let mut stmt = conn.prepare("SELECT COUNT(*) FROM users WHERE email = ?1")?;
    let email_count: i64 = stmt.query_row([email], |row| row.get(0))?;

    if email_count > 0 {
        return Err(DatabaseError::EmailExists);
    }

    // Check if the username already exists
    let mut stmt = conn.prepare("SELECT COUNT(*) FROM users WHERE username = ?1")?;
    let username_count: i64 = stmt.query_row([username], |row| row.get(0))?;

    if username_count > 0 {
        return Err(DatabaseError::UsernameExists);
    }

    // Hash the password using bcrypt
    let hashed_password = bcrypt::hash(password, bcrypt::DEFAULT_COST).unwrap();

    conn.execute(
        "INSERT INTO users (
        email, username, password) VALUES (?1, ?2, ?3)",
        params![email, username, hashed_password],
    )?;

    let user_id = conn.last_insert_rowid() as u64;

    let mut stmt = conn.prepare(
        "SELECT 
        id, avatar, email, username, password FROM users WHERE id = ?1",
    )?;

    let user = stmt.query_row(params![user_id], |row| {
        Ok(User {
            id: row.get("id")?,
            avatar: row.get("avatar")?,
            email: row.get("email")?,
            username: row.get("username")?,
        })
    })?;

    Ok(user)
}
