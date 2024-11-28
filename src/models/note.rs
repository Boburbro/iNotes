use serde::{Deserialize, Serialize};

#[derive(Serialize, Deserialize)]
pub struct Note {
    pub id: u32,
    pub title: String,
    pub content: String,
    pub category: String,
    pub delta: Option<String>,
    pub created_at: String,
    pub updated_at: Option<String>,
}

#[derive(Serialize, Deserialize, Debug, Clone)]
pub struct NewNote {
    pub title: String,
    pub content: String,
    pub delta: Option<String>,
    pub category: String,
}
