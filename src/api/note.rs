use actix_multipart::Multipart;
use actix_web::{get, post, web, HttpRequest, HttpResponse, Responder};
use log::error;
use serde_json::json;

use crate::{
    db,
    models::{
        ApiResponse, JsonParams, NewCategory, QueryParams, RequestContext, RequestContextParams,
        ResponseBuilder,
    },
    state::AppState,
};

#[post("/note")]
async fn add_note(
    json: web::Json<JsonParams>,
    req: HttpRequest,
    data: web::Data<AppState>,
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

    let note = json_params.new_note;

    match db::add_note_to_db(&context.conn, note) {
        Ok(note) => HttpResponse::Ok().json(note),
        Err(e) => {
            error!("Failed to add note to database: {}", e);
            HttpResponse::InternalServerError().json(json!({
                "message": "Internal Server Error"
            }))
        }
    }
}

#[get("/notes")]
async fn fetch_notes(
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

    let pagination = context.pagination();

    match db::fetch_notes_from_db(&context.conn, pagination.per_page, pagination.offset) {
        Ok(notes) => {
            let total = notes.len() as u32;
            let response = ApiResponse::build(notes, total, &pagination);
            HttpResponse::Ok().json(response)
        }
        Err(e) => {
            error!("Failed to fetch notes from database: {}", e);
            HttpResponse::InternalServerError().json(json!({
                "message": "Internal Server Error"
            }))
        }
    }
}

#[get("/recent-notes")]
async fn fetch_recent_notes(
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

    let pagination = context.pagination();

    match db::fetch_recent_notes_from_db(&context.conn) {
        Ok(notes) => {
            let total = notes.len() as u32;
            let response = ApiResponse::build(notes, total, &pagination);
            HttpResponse::Ok().json(response)
        }
        Err(e) => {
            error!("Failed to fetch recent notes from database: {}", e);
            HttpResponse::InternalServerError().json(json!({
                "message": "Internal Server Error"
            }))
        }
    }
}

#[get("/categories")]
async fn fetch_categories(req: HttpRequest, data: web::Data<AppState>) -> impl Responder {
    let params = RequestContextParams {
        ..Default::default()
    };

    let context = match RequestContext::new(req, &data, params) {
        Ok(ctx) => ctx,
        Err(err) => return err,
    };

    let pagination = context.pagination();

    match db::fetch_categories_from_db(&context.conn) {
        Ok(categories) => {
            let total = categories.len() as u32;
            let response = ApiResponse::build(categories, total, &pagination);
            HttpResponse::Ok().json(response)
        }
        Err(e) => {
            error!("Failed to fetch categories from database: {}", e);
            HttpResponse::InternalServerError().json(json!({
                "message": "Internal Server Error"
            }))
        }
    }
}

#[post("/category")]
async fn add_category(
    multipart: Multipart,
    req: HttpRequest,
    data: web::Data<AppState>,
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
        let name = multipart_data
            .get("name")
            .and_then(|v| String::from_utf8(v.clone()).ok())
            .filter(|s| !s.is_empty());

        let color = multipart_data.get("color").and_then(|v| {
            let color_str = String::from_utf8(v.clone()).ok()?;
            let color_str = color_str.trim_start_matches("0x");
            u32::from_str_radix(color_str, 16).ok()
        });

        let avatar: Option<Vec<u8>> = multipart_data
            .iter()
            .filter(|(key, value)| key.starts_with("avatar") && !value.is_empty())
            .next()
            .map(|(_, value)| value.clone());

        let missing_fields: Vec<&str> = [
            ("name", name.is_none()),
            ("avatar", avatar.is_none()),
            ("color", color.is_none()),
        ]
        .iter()
        .filter_map(|(field, is_missing)| if *is_missing { Some(*field) } else { None })
        .collect();

        if !missing_fields.is_empty() {
            return HttpResponse::BadRequest()
                .body(format!("Missing required fields: {:?}", missing_fields));
        }

        let new_category = NewCategory {
            name: name.unwrap(),
            color: color.unwrap(),
            avatar: avatar.unwrap(),
        };

        match db::add_category_to_db(&context.conn, new_category) {
            Ok(product) => HttpResponse::Created().json(product),
            Err(err) => {
                println!("Error adding category to database: {:?}", err);
                HttpResponse::BadRequest().json(json!({"message": err.to_string()}))
            }
        }
    } else {
        return HttpResponse::BadRequest().body("Invalid multipart data");
    }
}
