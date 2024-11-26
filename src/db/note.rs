use r2d2::PooledConnection;
use r2d2_sqlite::SqliteConnectionManager;
use rusqlite::{params, Error};

use crate::models::{NewNote, Note};

pub fn add_note_to_db(
    conn: &PooledConnection<SqliteConnectionManager>,
    note: NewNote,
) -> Result<Note, Error> {
    match conn.execute(
        "INSERT INTO notes (title, content, category, created_at, updated_at) 
        VALUES (?1, ?2, ?3, datetime('now'), NULL)",
        params![note.title, note.content, note.category],
    ) {
        Ok(_) => (),
        Err(e) => {
            println!("Error inserting note: {:?}", e);
            return Err(e);
        }
    }

    let id = conn.last_insert_rowid() as u32;
    println!("Last inserted row id: {}", id);

    Ok(Note {
        id: id,
        title: note.title,
        content: note.content,
        category: note.category,
        created_at: chrono::Utc::now().to_rfc3339(),
        updated_at: None,
    })
}

pub fn fetch_notes_from_db(
    conn: &PooledConnection<SqliteConnectionManager>,
    limit: u8,
    offset: u16,
) -> Result<Vec<Note>, Error> {
    let sql = "
    SELECT id, title, content, category, created_at, updated_at 
    FROM notes
    LIMIT ?1 OFFSET ?2";

    let mut stmt = conn.prepare(sql).unwrap();

    let note_iter = stmt.query_map([limit as u8, offset as u8], |row| {
        Ok(Note {
            id: row.get("id")?,
            title: row.get("title")?,
            content: row.get("content")?,
            category: row.get("category")?,
            created_at: row.get("created_at")?,
            updated_at: row.get("updated_at")?,
        })
    })?;

    let mut notes = Vec::new();

    for note in note_iter {
        notes.push(note.unwrap());
    }

    Ok(notes)
}
