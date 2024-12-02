use crate::utils::color_to_hex;
use serde::{Deserialize, Serialize};

#[derive(Serialize, Deserialize)]
pub struct Note {
    pub id: u32,
    pub user_id: u32,
    pub category_id: u32,
    pub title: String,
    pub content: String,
    pub category: String,
    pub delta: Option<String>,
    pub created_at: String,
    pub updated_at: Option<String>,
    #[serde(serialize_with = "color_to_hex")]
    pub color: u32,
}

#[derive(Serialize, Deserialize, Debug, Clone)]
pub struct NewNote {
    pub user_id: u32,
    pub category_id: u32,
    pub title: String,
    pub content: String,
    pub delta: Option<String>,
    pub category: String,
    pub color: u32,
}
