use actix_multipart::Multipart;
use actix_web::{delete, get, post, put, web, HttpRequest, HttpResponse, Responder};
use log::error;
use serde_json::json;

use crate::{
    db,
    models::{
        ApiResponse, JsonParams, NewNote, PathParams, QueryParams, RequestContext,
        RequestContextParams, ResponseBuilder,
    },
    state::AppState,
};

#[post("/note")]
async fn add_note(
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
        let user_id = multipart_data
            .get("user_id")
            .and_then(|v| String::from_utf8(v.clone()).ok())
            .and_then(|v| v.parse::<u32>().ok());

        let category_id = multipart_data
            .get("category_id")
            .and_then(|v| String::from_utf8(v.clone()).ok())
            .and_then(|v| v.parse::<u32>().ok());

        let title = multipart_data
            .get("title")
            .and_then(|v| String::from_utf8(v.clone()).ok())
            .filter(|s| !s.is_empty());

        let content = multipart_data
            .get("content")
            .and_then(|v| String::from_utf8(v.clone()).ok())
            .filter(|s| !s.is_empty());

        let category = multipart_data
            .get("category")
            .and_then(|v| String::from_utf8(v.clone()).ok())
            .filter(|s| !s.is_empty());

        let delta = multipart_data
            .get("delta")
            .and_then(|v| String::from_utf8(v.clone()).ok())
            .filter(|s| !s.is_empty());

        let color = multipart_data.get("color").and_then(|v| {
            let color_str = String::from_utf8(v.clone()).ok()?;
            let color_str = color_str.trim_start_matches("0x");
            u32::from_str_radix(color_str, 16).ok()
        });

        let missing_fields: Vec<&str> = [
            ("user_id", user_id.is_none()),
            ("category_id", category_id.is_none()),
            ("title", title.is_none()),
            ("content", content.is_none()),
            ("category", category.is_none()),
            ("delta", delta.is_none()),
            ("color", color.is_none()),
        ]
        .iter()
        .filter_map(|(field, is_missing)| if *is_missing { Some(*field) } else { None })
        .collect();

        if !missing_fields.is_empty() {
            return HttpResponse::BadRequest()
                .body(format!("Missing required fields: {:?}", missing_fields));
        }

        let new_note = NewNote {
            user_id: user_id.unwrap(),
            category_id: category_id.unwrap(),
            title: title.unwrap(),
            content: content.unwrap(),
            category: category.unwrap(),
            delta: Some(delta.unwrap()),
            color: color.unwrap(),
        };

        match db::add_note_to_db(&context.conn, new_note) {
            Ok(note) => HttpResponse::Created().json(note),
            Err(e) => {
                error!("Failed to add note to database: {}", e);
                HttpResponse::InternalServerError().json(json!({
                    "message": "Internal Server Error"
                }))
            }
        }
    } else {
        return HttpResponse::BadRequest().body("Invalid multipart data");
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
    let query_params = context.params.query_params.unwrap();
    let user_id = query_params.user_id.unwrap();

    match db::fetch_notes_from_db(
        &context.conn,
        pagination.per_page,
        pagination.offset,
        user_id,
    ) {
        Ok(notes) => {
            let total = notes.len() as u32;
            let response = ApiResponse::build(notes, total, &pagination);
            HttpResponse::Ok().json(response)
        }
        Err(e) => {
            error!("Failed to fetch notes from database: {}", e);
            HttpResponse::InternalServerError().json(json!({
                "message": e.to_string()
            }))
        }
    }
}

#[get("/notes-by-category")]
async fn fetch_notes_by_category(
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
    let query_params = context.params.query_params.unwrap();
    let user_id = query_params.user_id.unwrap();
    let category_id = query_params.category_id.unwrap();

    match db::fetch_notes_by_category_from_db(
        &context.conn,
        pagination.per_page,
        pagination.offset,
        user_id,
        category_id,
    ) {
        Ok(notes) => {
            let total = notes.len() as u32;
            let response = ApiResponse::build(notes, total, &pagination);
            HttpResponse::Ok().json(response)
        }
        Err(e) => {
            error!("Failed to fetch notes from database: {}", e);
            HttpResponse::InternalServerError().json(json!({
                "message": e.to_string()
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
    let query_params = context.params.query_params.unwrap();
    let user_id = query_params.user_id.unwrap();

    match db::fetch_recent_notes_from_db(&context.conn, user_id) {
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

#[delete("/note")]
async fn delete_note(
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
    let note_id = query_params.note_id.unwrap();
    let category_id = query_params.category_id.unwrap();

    match db::delete_note_from_db(&context.conn, note_id, user_id, category_id) {
        Ok(_) => HttpResponse::NoContent().finish(),
        Err(e) => {
            error!("Failed to delete note from database: {}", e);
            HttpResponse::InternalServerError().json(json!({
                "message": e.to_string()
            }))
        }
    }
}

#[put("/note")]
async fn update_note(
    req: HttpRequest,
    data: web::Data<AppState>,
    json: web::Json<JsonParams>,
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
    let user_id = json_params.user_id.unwrap();
    let note_id = json_params.note_id.unwrap();
    let title = json_params.title.as_ref().map(|s| s.as_str()).unwrap_or("");
    let content = json_params
        .content
        .as_ref()
        .map(|s| s.as_str())
        .unwrap_or("");
    let delta = json_params.delta.as_ref().map(|s| s.as_str()).unwrap_or("");

    match db::update_note_in_db(&context.conn, note_id, user_id, title, content, delta) {
        Ok(note) => HttpResponse::Ok().json(note),
        Err(e) => {
            error!("Failed to update note in database: {}", e);
            HttpResponse::InternalServerError().json(json!({
                "message": e.to_string()
            }))
        }
    }
}

#[post("/notes/{query}")]
async fn search_for_note(
    req: HttpRequest,
    data: web::Data<AppState>,
    path: web::Path<PathParams>,
) -> impl Responder {
    let params = RequestContextParams {
        path_params: Some(path.into_inner()),
        ..Default::default()
    };

    let context = match RequestContext::new(req, &data, params) {
        Ok(ctx) => ctx,
        Err(err) => return err,
    };

    let pagination = context.pagination();

    let path = context.params.path_params.unwrap();
    let query_string = path.query.unwrap();
    let query = query_string.as_str();

    match db::search_for_note_in_db(&context.conn, query) {
        Ok(notes) => {
            let total = notes.len() as u32;
            let response = ApiResponse::build(notes, total, &pagination);
            HttpResponse::Ok().json(response)
        }
        Err(e) => {
            error!("Failed to search for note in database: {}", e);
            HttpResponse::InternalServerError().json(json!({
                "message": e.to_string()
            }))
        }
    }
}
