use actix_web::{post, web, HttpResponse, Responder};
use log::error;
use serde_json::json;

use crate::{
    db,
    models::{LoginForm, RegisterForm, EMAIL_REGEX, USERNAME_REGEX},
    state::AppState,
};

#[post("/auth/login")]
async fn login(data: web::Data<AppState>, form: web::Json<LoginForm>) -> impl Responder {
    let conn = data
        .pool
        .get()
        .map_err(|e| {
            error!("Failed to get connection from pool: {}", e);
            return HttpResponse::InternalServerError().json(json!({"message:":e.to_string()}));
        })
        .unwrap();

    match db::login(&form.username, &form.password, &conn) {
        Ok(user) => {
            let response = json!({
                "user": user
            });
            HttpResponse::Ok().json(response)
        }

        Err(err) => {
            error!("Login error: {}", err);
            return HttpResponse::InternalServerError()
                .body(serde_json::to_string(&json!({"message": err.to_string()})).unwrap());
        }
    }
}

#[post("/auth/register")]
async fn register(data: web::Data<AppState>, form: web::Json<RegisterForm>) -> impl Responder {
    // Validate email, username, and name
    let is_email = EMAIL_REGEX.is_match(&form.email);
    let is_username = USERNAME_REGEX.is_match(&form.username);

    if !is_email {
        return HttpResponse::BadRequest()
            .body(serde_json::to_string(&json!({"message": "Invalid email format"})).unwrap());
    }

    if !is_username {
        return HttpResponse::BadRequest()
            .body(serde_json::to_string(&json!({"message": "Invalid username format"})).unwrap());
    }

    // Validate password
    if !is_valid_password(&form.password) {
        return HttpResponse::BadRequest().body(serde_json::to_string(&json!({"message": "Invalid password. It must be at least 8 characters long and contain at least 1 uppercase letter, 1 lowercase letter, 1 number, and 1 special character."})).unwrap());
    }

    let conn = data
        .pool
        .get()
        .map_err(|e| {
            error!("Failed to get connection from pool: {}", e);
            return HttpResponse::InternalServerError().body(
                serde_json::to_string(&json!({"message": "Internal Server Error"})).unwrap(),
            );
        })
        .unwrap();

    match db::register(&form.email, &form.username, &form.password, &conn) {
        Ok(user) => {
            let response = json!({
                "user":user,
            });
            HttpResponse::Created().json(response)
        }

        Err(err) => {
            error!("Registration error: {}", err);
            return HttpResponse::InternalServerError()
                .body(serde_json::to_string(&json!({"message": err.to_string()})).unwrap());
        }
    }
}

pub fn is_valid_password(password: &str) -> bool {
    let has_min_length = password.len() >= 8 && password.len() <= 25;
    has_min_length
}
