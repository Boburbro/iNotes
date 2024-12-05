use thiserror::Error;

#[derive(Error, Debug)]
pub enum DatabaseError {
    #[error("Rusqlite error")]
    Rusqlite(#[from] rusqlite::Error),

    #[error("Serde JSON error")]
    SerdeJson(#[from] serde_json::Error),

    #[error("Category already exists")]
    CategoryExists,
}
