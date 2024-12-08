use thiserror::Error;

#[derive(Error, Debug)]
pub enum DatabaseError {
    // Authentication errors
    #[error("Email already exists")]
    EmailExists,

    #[error("Username or password incorrect")]
    IncorrectCredentials,

    #[error("User not found")]
    UserNotFound,

    #[error("Username already exists")]
    UsernameExists,

    // Category errors
    #[error("Category already exists")]
    CategoryExists,

    // Other errors
    #[error("Internal server error")]
    InternalServerError,

    #[error("Rusqlite error")]
    Rusqlite(#[from] rusqlite::Error),

    #[error("Serde JSON error")]
    SerdeJson(#[from] serde_json::Error),
}
