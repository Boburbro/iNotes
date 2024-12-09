use r2d2::PooledConnection;
use r2d2_sqlite::SqliteConnectionManager;
use rusqlite::{params, Error};

use crate::models::{Category, NewNote, Note};

pub fn add_note_to_db(
    conn: &PooledConnection<SqliteConnectionManager>,
    note: NewNote,
) -> Result<Note, Error> {
    // let category_name = note.category.name;

    // Check if the category exists for the user
    let category_exists: bool = conn
        .query_row(
            "SELECT EXISTS(SELECT 1 FROM categories WHERE name = ?1 AND user_id = ?2)",
            params![note.category, note.user_id],
            |row| row.get(0),
        )
        .unwrap_or(false);

    // If the category doesn't exist, return an error
    if !category_exists {
        return Err(Error::QueryReturnedNoRows);
    }

    // Insert the note into the database
    match conn.execute(
        "INSERT INTO notes (user_id, category_id, title, content, category, delta, created_at, updated_at, color) 
        VALUES (?1, ?2, ?3, ?4, ?5, ?6, datetime('now'), NULL, ?7)",
        params![note.user_id, note.category_id, note.title, note.content, note.category, note.delta, note.color],
    ) {
        Ok(_) => (),
        Err(e) => {
            println!("Error inserting note: {:?}", e);
            return Err(e);
        }
    }

    // Update the notes count in the category
    match conn.execute(
        "UPDATE categories SET notes_count = notes_count + 1 WHERE name = ?1 AND user_id = ?2",
        params![note.category, note.user_id],
    ) {
        Ok(_) => (),
        Err(e) => {
            println!("Error updating category notes_count: {:?}", e);
            return Err(e);
        }
    }

    // Retrieve the last inserted note ID
    let id = conn.last_insert_rowid() as u32;

    let sql = "SELECT categories.id, categories.user_id,
                     categories.notes_count, categories.avatar, 
                     categories.color, categories.name 
                FROM categories
                JOIN users ON categories.user_id = users.id
                WHERE users.id = ?1
                ORDER BY categories.notes_count DESC";
    let mut stmt = conn.prepare(sql).unwrap();

    let category = stmt.query_row([note.user_id], |row| {
        let category = Category {
            id: row.get("id")?,
            user_id: row.get("user_id")?,
            notes_count: row.get("notes_count")?,
            avatar: row.get("avatar")?,
            color: row.get("color")?,
            name: row.get("name")?,
        };

        Ok(category)
    })?;

    // Return the new note
    Ok(Note {
        id,
        user_id: note.user_id,
        category_id: note.category_id,
        title: note.title,
        content: note.content,
        category: category,
        delta: note.delta,
        created_at: chrono::Utc::now().to_rfc3339(),
        updated_at: None,
        color: note.color,
    })
}

pub fn fetch_notes_by_category_from_db(
    conn: &PooledConnection<SqliteConnectionManager>,
    limit: u8,
    offset: u16,
    user_id: u32,
    category_id: u32,
) -> Result<Vec<Note>, Error> {
    let sql = "
    SELECT notes.id, notes.category_id, notes.user_id, 
           notes.title, notes.content, notes.delta, 
           notes.created_at, notes.updated_at, notes.color,
           categories.id AS category_id, categories.user_id AS category_user_id, 
           categories.name, categories.avatar, categories.notes_count, 
           categories.color AS category_color
    FROM notes
    JOIN users ON notes.user_id = users.id
    JOIN categories ON notes.category_id = categories.id
    WHERE users.id = ?1 AND notes.category_id = ?2
    ORDER BY notes.created_at DESC
    LIMIT ?3 OFFSET ?4";

    let mut stmt = conn.prepare(sql)?;

    let note_iter = stmt.query_map([user_id, category_id, limit as u32, offset as u32], |row| {
        Ok(Note {
            id: row.get("id")?,
            user_id: row.get("user_id")?,
            category_id: row.get("category_id")?,
            title: row.get("title")?,
            content: row.get("content")?,
            category: Category {
                id: row.get("category_id")?,
                user_id: row.get("category_user_id")?,
                name: row.get("name")?,
                avatar: row.get("avatar")?,
                notes_count: row.get("notes_count")?,
                color: row.get("category_color")?,
            },
            delta: row.get("delta")?,
            created_at: row.get("created_at")?,
            updated_at: row.get("updated_at")?,
            color: row.get("color")?,
        })
    })?;

    let mut notes = Vec::new();
    for note in note_iter {
        notes.push(note?);
    }

    Ok(notes)
}

pub fn fetch_recent_notes_from_db(
    conn: &PooledConnection<SqliteConnectionManager>,
    user_id: u32,
) -> Result<Vec<Note>, Error> {
    let sql = "
    SELECT notes.id, notes.category_id, notes.user_id, 
           notes.title, notes.content, notes.delta, 
           notes.created_at, notes.updated_at, notes.color,
           categories.id AS category_id, categories.user_id AS category_user_id, 
           categories.name, categories.avatar, categories.notes_count, 
           categories.color AS category_color
    FROM notes
    JOIN users ON notes.user_id = users.id
    JOIN categories ON notes.category_id = categories.id
    WHERE users.id = ?1
    ORDER BY notes.created_at DESC
    LIMIT 3";

    let mut stmt = conn.prepare(sql)?;

    let notes_iter = stmt.query_map([user_id], |row| {
        Ok(Note {
            id: row.get("id")?,
            user_id: row.get("user_id")?,
            category_id: row.get("category_id")?,
            title: row.get("title")?,
            content: row.get("content")?,
            delta: row.get("delta")?,
            category: Category {
                id: row.get("category_id")?,
                user_id: row.get("category_user_id")?,
                name: row.get("name")?,
                avatar: row.get("avatar")?,
                notes_count: row.get("notes_count")?,
                color: row.get("category_color")?,
            },
            created_at: row.get("created_at")?,
            updated_at: row.get("updated_at")?,
            color: row.get("color")?,
        })
    })?;

    let notes: Vec<Note> = notes_iter.map(|note| note.unwrap()).collect();
    Ok(notes)
}

pub fn delete_note_from_db(
    conn: &PooledConnection<SqliteConnectionManager>,
    note_id: u32,
    user_id: u32,
    category_id: u32,
) -> Result<(), Error> {
    let sql = "DELETE FROM notes WHERE id = ?1 AND user_id = ?2";

    let mut stmt = conn.prepare(sql)?;
    let rows_affected = stmt.execute([note_id, user_id])?;

    // Check if the note was successfully deleted
    if rows_affected == 0 {
        Err(Error::QueryReturnedNoRows)
    } else {
        // Successfully deleted the note
        match conn.execute(
            "UPDATE categories SET notes_count = notes_count - 1 WHERE id = ?1 AND user_id = ?2",
            params![category_id, user_id],
        ) {
            Ok(_) => Ok(()),
            Err(e) => {
                println!("Error updating category notes_count: {:?}", e);
                return Err(e);
            }
        }
    }
}

pub fn update_note_in_db(
    conn: &PooledConnection<SqliteConnectionManager>,
    note_id: u32,
    user_id: u32,
    title: &str,
    content: &str,
    delta: &str,
) -> Result<Note, Error> {
    // Update the note
    let update_sql = "
    UPDATE notes 
    SET title = ?1, 
        content = ?2, 
        delta = ?3, 
        updated_at = CURRENT_TIMESTAMP
    WHERE id = ?4 AND user_id = ?5";

    let mut stmt = conn.prepare(update_sql)?;
    let rows_affected = stmt.execute(params![title, content, delta, note_id, user_id])?;

    if rows_affected == 0 {
        return Err(Error::QueryReturnedNoRows);
    }

    // Fetch the updated note with category details
    let fetch_sql = "
    SELECT notes.id, notes.category_id, notes.user_id, 
           notes.title, notes.content, notes.delta, 
           notes.created_at, notes.updated_at, notes.color,
           categories.id AS category_id, categories.user_id AS category_user_id, 
           categories.name, categories.avatar, categories.notes_count, 
           categories.color AS category_color
    FROM notes
    JOIN categories ON notes.category_id = categories.id
    WHERE notes.id = ?1 AND notes.user_id = ?2";

    let mut stmt = conn.prepare(fetch_sql)?;
    let note = stmt.query_row([note_id, user_id], |row| {
        Ok(Note {
            id: row.get("id")?,
            user_id: row.get("user_id")?,
            category_id: row.get("category_id")?,
            title: row.get("title")?,
            content: row.get("content")?,
            delta: row.get("delta")?,
            category: Category {
                id: row.get("category_id")?,
                user_id: row.get("category_user_id")?,
                name: row.get("name")?,
                avatar: row.get("avatar")?,
                notes_count: row.get("notes_count")?,
                color: row.get("category_color")?,
            },
            created_at: row.get("created_at")?,
            updated_at: row.get("updated_at")?,
            color: row.get("color")?,
        })
    })?;

    Ok(note)
}

pub fn search_for_note_in_db(
    conn: &PooledConnection<SqliteConnectionManager>,
    query: &str,
) -> Result<Vec<Note>, Error> {
    let sql = "
    SELECT notes.id, notes.category_id, notes.user_id, 
           notes.title, notes.content, notes.delta, 
           notes.created_at, notes.updated_at, notes.color,
           categories.id AS category_id, categories.user_id AS category_user_id, 
           categories.name, categories.avatar, categories.notes_count, 
           categories.color AS category_color
    FROM notes
    JOIN users ON notes.user_id = users.id
    JOIN categories ON notes.category_id = categories.id
    WHERE notes.title LIKE ?1 OR notes.content LIKE ?1
    ORDER BY notes.created_at DESC";

    let mut stmt = conn.prepare(sql)?;

    let like_query = format!("%{}%", query);
    let note_iter = stmt.query_map([like_query], |row| {
        Ok(Note {
            id: row.get("id")?,
            user_id: row.get("user_id")?,
            category_id: row.get("category_id")?,
            title: row.get("title")?,
            content: row.get("content")?,
            delta: row.get("delta")?,
            category: Category {
                id: row.get("category_id")?,
                user_id: row.get("category_user_id")?,
                name: row.get("name")?,
                avatar: row.get("avatar")?,
                notes_count: row.get("notes_count")?,
                color: row.get("category_color")?,
            },
            created_at: row.get("created_at")?,
            updated_at: row.get("updated_at")?,
            color: row.get("color")?,
        })
    })?;

    let mut notes = Vec::new();
    for note in note_iter {
        notes.push(note.unwrap());
    }

    Ok(notes)
}

pub fn search_for_notes_by_category_in_db(
    conn: &PooledConnection<SqliteConnectionManager>,
    query: &str,
    category: &str,
) -> Result<Vec<Note>, Error> {
    let sql = "
        SELECT notes.id, notes.category_id, notes.user_id, 
               notes.title, notes.content, notes.delta, 
               notes.created_at, notes.updated_at, notes.color,
               categories.id AS category_id, categories.user_id AS category_user_id, 
               categories.name, categories.avatar, categories.notes_count, 
               categories.color AS category_color
        FROM notes
        JOIN users ON notes.user_id = users.id
        JOIN categories ON notes.category_id = categories.id
        WHERE categories.name = ?2
          AND (
              ?1 IS NULL OR notes.title LIKE ?1 OR notes.content LIKE ?1
          )
        ORDER BY notes.created_at DESC";

    let mut stmt = conn.prepare(sql)?;

    let like_query = if query.is_empty() {
        None
    } else {
        Some(format!("%{}%", query))
    };

    let note_iter = stmt.query_map([like_query.as_deref(), Some(category)], |row| {
        Ok(Note {
            id: row.get("id")?,
            user_id: row.get("user_id")?,
            category_id: row.get("category_id")?,
            title: row.get("title")?,
            content: row.get("content")?,
            delta: row.get("delta")?,
            category: Category {
                id: row.get("category_id")?,
                user_id: row.get("category_user_id")?,
                name: row.get("name")?,
                avatar: row.get("avatar")?,
                notes_count: row.get("notes_count")?,
                color: row.get("category_color")?,
            },
            created_at: row.get("created_at")?,
            updated_at: row.get("updated_at")?,
            color: row.get("color")?,
        })
    })?;

    let mut notes = Vec::new();
    for note in note_iter {
        notes.push(note.unwrap());
    }

    Ok(notes)
}
