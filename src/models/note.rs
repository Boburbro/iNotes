use serde::{Deserialize, Serialize};

#[derive(Serialize, Deserialize)]
pub struct Note {
    pub id: u32,
    pub title: String,
    pub content: String,
    pub category: String,
    pub created_at: String,
    pub updated_at: Option<String>,
}

#[derive(Serialize, Deserialize)]
pub struct NewNote {
    pub title: String,
    pub content: String,
    pub category: String,
}
