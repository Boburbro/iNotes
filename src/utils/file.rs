use std::fs::{self, File};
use std::io::{self, Write};
use std::path::Path;
use uuid::Uuid;

pub fn save_image_to_disk(image_bytes: &[u8]) -> Result<String, io::Error> {
    let file_name = Uuid::new_v4().to_string() + ".png";
    let file_path = format!("./uploads/{}", file_name);

    // Ensure the uploads directory exists
    let uploads_dir = Path::new("./uploads");
    if !uploads_dir.exists() {
        fs::create_dir_all(uploads_dir)?;
    }

    let mut file = File::create(&file_path)?;

    // Write image bytes to the file
    file.write_all(image_bytes)?;

    let url = format!("http://localhost:8080/uploads/{}", file_name);

    Ok(url)
}
