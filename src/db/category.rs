use r2d2::PooledConnection;
use r2d2_sqlite::SqliteConnectionManager;
use rusqlite::{params, Error};

use crate::{
    models::{Category, NewCategory},
    utils::save_image_to_disk,
};

pub fn add_category_to_db(
    conn: &PooledConnection<SqliteConnectionManager>,
    category: NewCategory,
) -> Result<Category, Error> {
    let sql = "INSERT INTO categories (user_id, name, notes_count, color) 
                     VALUES (?1, ?2, 0, ?3)";

    conn.execute(
        sql,
        params![category.user_id, category.name, category.color],
    )?;

    let result = save_image_to_disk(&category.avatar).ok();
    let avatar = result.unwrap();

    let id = conn.last_insert_rowid() as u32;

    conn.execute(
        "UPDATE categories 
             SET avatar = ?1 
             WHERE id = ?2 AND user_id = ?3",
        params![avatar, id, category.user_id],
    )?;

    Ok(Category {
        id: id,
        user_id: category.user_id,
        name: category.name,
        avatar: avatar,
        notes_count: 0,
        color: category.color,
    })
}

pub fn fetch_categories_from_db(
    conn: &PooledConnection<SqliteConnectionManager>,
    user_id: u32,
) -> Result<Vec<Category>, Error> {
    let sql = "SELECT categories.id, categories.user_id,
                     categories.notes_count, categories.avatar, 
                     categories.color, categories.name 
    FROM categories
    JOIN users ON categories.user_id = users.id
    WHERE users.id = ?1
    ORDER BY categories.notes_count DESC";
    let mut stmt = conn.prepare(sql).unwrap();

    let category_iter = stmt.query_map([user_id], |row| {
        Ok(Category {
            id: row.get("id")?,
            user_id: row.get("user_id")?,
            name: row.get("name")?,
            avatar: row.get("avatar")?,
            notes_count: row.get("notes_count")?,
            color: row.get("color")?,
        })
    })?;

    let mut categories = Vec::new();

    for category in category_iter {
        categories.push(category.unwrap());
    }

    Ok(categories)
}
