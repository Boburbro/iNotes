use serde::{Deserialize, Serialize};

#[derive(Debug, Serialize, Deserialize)]
pub struct Category {
    pub id: u64,
    pub name: String,
    pub avatar: String,
    pub notes_count: u64,
}
