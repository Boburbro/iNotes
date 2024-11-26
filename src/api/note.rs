use actix_web::{get, post, web, HttpRequest, HttpResponse, Responder};
use log::error;
use serde_json::json;

use crate::{
    db,
    models::{
        ApiResponse, JsonParams, NewNote, QueryParams, RequestContext, RequestContextParams,
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

    let note = NewNote {
        title: json_params.title.unwrap(),
        content: json_params.content.unwrap(),
        category: json_params.category.unwrap(),
    };

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
