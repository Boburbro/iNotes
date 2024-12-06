use thiserror::Error;

#[derive(Error, Debug)]
pub enum DatabaseError {
    #[error("Rusqlite error")]
    Rusqlite(#[from] rusqlite::Error),

    #[error("Serde JSON error")]
    SerdeJson(#[from] serde_json::Error),

    // Category errors
    #[error("Category already exists")]
    CategoryExists,

    // Authentication errors
    #[error("Email already exists")]
    EmailExists,

    #[error("Username already exists")]
    UsernameExists,

    #[error("Username or password incorrect")]
    IncorrectCredentials,

    #[error("Internal server error")]
    InternalServerError,

    #[error("User not found")]
    UserNotFound,
}
