use crate::utils::color_to_hex;
use serde::{Deserialize, Serialize};

#[derive(Debug, Serialize, Deserialize)]
pub struct Category {
    pub id: u64,
    pub name: String,
    pub avatar: String,
    pub notes_count: u64,
    #[serde(serialize_with = "color_to_hex")]
    pub color: u32,
}

#[derive(Debug, Serialize, Deserialize)]
pub struct NewCategory {
    pub name: String,
    pub avatar: Vec<u8>,
    pub color: u32,
}
