use actix_web::{post, web, HttpResponse, Responder};
use log::error;
use serde_json::{json, Value};

use crate::{
    db,
    models::{
        JsonParams, LoginForm, RegisterForm, RequestContext, RequestContextParams, EMAIL_REGEX,
        USERNAME_REGEX,
    },
    state::AppState,
};

#[post("/auth/login")]
async fn login(
    data: web::Data<AppState>,
    json: web::Json<JsonParams>,
    req: actix_web::HttpRequest,
) -> impl Responder {
    let params = RequestContextParams {
        json_params: Some(json.into_inner()),
        ..Default::default()
    };

    let context = match RequestContext::new(req, &data, params) {
        Ok(ctx) => ctx,
        Err(err) => return err,
    };

    let json_params = context.params.json_params.unwrap();

    let json_value: Value = serde_json::json!({
        "username": json_params.username,
        "password": json_params.password,
    });

    let form = LoginForm::from_json(&json_value);

    match db::login(&form.username, &form.password, &context.conn) {
        Ok(user) => {
            let response = json!({"user": user});
            HttpResponse::Ok().json(response)
        }

        Err(error_message) => {
            error!("Login error: {}", error_message);
            let json = &json!({"message": error_message.to_string()});
            return HttpResponse::InternalServerError().body(serde_json::to_string(json).unwrap());
        }
    }
}

#[post("/auth/register")]
async fn register(
    data: web::Data<AppState>,
    json: web::Json<JsonParams>,
    req: actix_web::HttpRequest,
) -> impl Responder {
    let params = RequestContextParams {
        json_params: Some(json.into_inner()),
        ..Default::default()
    };

    let context = match RequestContext::new(req, &data, params) {
        Ok(ctx) => ctx,
        Err(err) => return err,
    };

    let json_params = context.params.json_params.unwrap();

    let json_value: Value = serde_json::json!({
        "email": json_params.email,
        "username": json_params.username,
        "password": json_params.password,
    });

    let form = RegisterForm::from_json(&json_value);

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

    match db::register(&form.email, &form.username, &form.password, &context.conn) {
        Ok(user) => {
            let response = json!({"user":user});
            HttpResponse::Created().json(response)
        }

        Err(error_message) => {
            error!("Registration error: {}", error_message);
            let json = &json!({"message": error_message.to_string()});
            return HttpResponse::InternalServerError().body(serde_json::to_string(json).unwrap());
        }
    }
}

pub fn is_valid_password(password: &str) -> bool {
    let has_min_length = password.len() >= 8 && password.len() <= 25;
    has_min_length
}
