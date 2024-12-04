mod errors;

pub mod api;
pub mod db;
pub mod models;
pub mod state;

mod utils;

use actix_files::Files;
use actix_web::{web, App, HttpServer};
use r2d2::Pool;
use r2d2_sqlite::SqliteConnectionManager;
use state::AppState;
use std::env;

#[actix_web::main]
async fn main() -> std::io::Result<()> {
    env::set_var("RUST_LOG", "my_app=debug");
    env_logger::init();
    dotenv::dotenv().ok();

    let database_url = env::var("DATABASE_URL").expect("DATABASE_URL must be set");
    let manager = SqliteConnectionManager::file(database_url);
    let pool = Pool::new(manager).unwrap();
    let data = web::Data::new(AppState { pool });

    HttpServer::new(move || {
        App::new()
            .app_data(data.clone())
            .service(api::register)
            .service(api::login)
            .service(api::get_user)
            .service(api::update_profile_picture)
            .service(api::add_note)
            .service(api::fetch_notes)
            .service(api::fetch_recent_notes)
            .service(api::delete_note)
            .service(api::update_note)
            .service(api::search_for_note)
            .service(api::fetch_notes_by_category)
            .service(api::add_category)
            .service(api::fetch_categories)
            .service(api::delete_account)
            .service(api::delete_category)
            .service(Files::new("/uploads", "./uploads").show_files_listing())
    })
    .bind("127.0.0.1:8080")?
    .run()
    .await
}
