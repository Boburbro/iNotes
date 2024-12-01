use actix_multipart::Multipart;
use actix_web::{get, post, web, HttpRequest, HttpResponse, Responder};
use log::error;
use serde_json::json;

use crate::{
    db,
    models::{NewUser, QueryParams, RequestContext, RequestContextParams},
    state::AppState,
};

#[get("/user")]
async fn get_user(
    req: HttpRequest,
    data: web::Data<AppState>,
    query: web::Query<QueryParams>,
) -> impl Responder {
    let params = RequestContextParams {
        query_params: Some(query.into_inner()),
        ..Default::default()
    };

    let context = match RequestContext::new(req, &data, params) {
        Ok(ctx) => ctx,
        Err(err) => return err,
    };

    let query_params = context.params.query_params.unwrap();
    let user_id = query_params.user_id.unwrap();

    match db::get_me(&context.conn, user_id) {
        Ok(user) => HttpResponse::Ok().json(user),
        Err(e) => {
            error!("Failed to fetch user from database: {}", e);
            HttpResponse::InternalServerError().json(json!({
                "message": e.to_string()
            }))
        }
    }
}

#[post("/update-profile-picture")]
async fn update_profile_picture(
    req: HttpRequest,
    data: web::Data<AppState>,
    multipart: Multipart,
) -> impl Responder {
    let multipart_params = match RequestContext::process_multipart(multipart).await {
        Ok(data) => Some(data),
        Err(err) => return err,
    };

    let params = RequestContextParams {
        multipart_params,
        ..Default::default()
    };

    let context = match RequestContext::new(req, &data, params) {
        Ok(ctx) => ctx,
        Err(err) => return err,
    };

    if let Some(multipart_data) = context.params.multipart_params {
        let user_id = multipart_data
            .get("user_id")
            .and_then(|v| String::from_utf8(v.clone()).ok())
            .and_then(|v| v.parse::<u32>().ok());

        let avatar: Option<Vec<u8>> = multipart_data
            .iter()
            .filter(|(key, value)| key.starts_with("avatar") && !value.is_empty())
            .next()
            .map(|(_, value)| value.clone());

        let missing_fields: Vec<&str> = [
            ("user_id", user_id.is_none()),
            ("avatar", avatar.is_none()),
        ]
        .iter()
        .filter_map(|(field, is_missing)| if *is_missing { Some(*field) } else { None })
        .collect();

        if !missing_fields.is_empty() {
            return HttpResponse::BadRequest()
                .body(format!("Missing required fields: {:?}", missing_fields));
        }

        let new_user = NewUser {
            id: user_id.unwrap(),
            avatar: avatar,
        };

        match db::update_profile_picture(&context.conn, new_user) {
            Ok(user) => HttpResponse::Created().json(user),
            Err(err) => {
                println!("Error updating profile picture: {:?}", err);
                HttpResponse::BadRequest().json(json!({"message": err.to_string()}))
            }
        }
    } else {
        return HttpResponse::BadRequest().body("Invalid multipart data");
    }
}
