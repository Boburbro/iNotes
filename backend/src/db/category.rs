use r2d2::PooledConnection;
use r2d2_sqlite::SqliteConnectionManager;
use rusqlite::{params, Error};

use crate::{
    errors::DatabaseError,
    models::{Category, NewCategory},
    utils::save_image_to_disk,
};

pub fn add_category_to_db(
    conn: &PooledConnection<SqliteConnectionManager>,
    category: NewCategory,
) -> Result<Category, DatabaseError> {
    // Check if the category already exists
    let exists: bool = conn.query_row(
        "SELECT EXISTS(SELECT 1 FROM categories WHERE user_id = ?1 AND name = ?2)",
        params![category.user_id, category.name],
        |row| row.get(0),
    )?;

    if exists {
        return Err(DatabaseError::CategoryExists);
    }

    // Insert the new category
    let sql = "INSERT INTO categories (user_id, name, notes_count, color) 
                     VALUES (?1, ?2, 0, ?3)";
    conn.execute(
        sql,
        params![category.user_id, category.name, category.color],
    )?;

    // Save the avatar to disk
    let result = save_image_to_disk(&category.avatar).ok();
    let avatar = result.unwrap();

    let id = conn.last_insert_rowid() as u32;

    // Update the avatar path in the database
    conn.execute(
        "UPDATE categories 
             SET avatar = ?1 
             WHERE id = ?2 AND user_id = ?3",
        params![avatar, id, category.user_id],
    )?;

    // Return the created category
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

pub fn delete_category_from_db(
    conn: &PooledConnection<SqliteConnectionManager>,
    user_id: u32,
    category_id: u32,
) -> Result<(), Error> {
    let sql = "DELETE FROM categories WHERE id = ?1 AND user_id = ?2";
    conn.execute(sql, params![category_id, user_id])?;
    Ok(())
}
