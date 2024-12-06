use actix_multipart::Multipart;
use actix_web::{delete, get, post, web, HttpRequest, HttpResponse, Responder};
use log::error;
use serde_json::json;

use crate::{
    db,
    models::{
        ApiResponse, NewCategory, QueryParams, RequestContext, RequestContextParams,
        ResponseBuilder,
    },
    state::AppState,
};

#[get("/categories")]
async fn fetch_categories(
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

    match db::fetch_categories_from_db(&context.conn, user_id) {
        Ok(categories) => {
            let total = categories.len() as u32;
            let response = ApiResponse::build(categories, total, &pagination);
            HttpResponse::Ok().json(response)
        }
        Err(error_message) => HttpResponse::InternalServerError().json(json!({
            "message": error_message.to_string()
        })),
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
        let user_id = multipart_data
            .get("user_id")
            .and_then(|v| String::from_utf8(v.clone()).ok())
            .and_then(|v| v.parse::<u32>().ok());

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
            ("user_id", user_id.is_none()),
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
            user_id: user_id.unwrap(),
            name: name.unwrap(),
            color: color.unwrap(),
            avatar: avatar.unwrap(),
        };

        match db::add_category_to_db(&context.conn, new_category) {
            Ok(product) => HttpResponse::Created().json(product),

            Err(error_message) => {
                let json = &json!({"message": error_message.to_string()});
                HttpResponse::InternalServerError().json(json)
            }
        }
    } else {
        return HttpResponse::BadRequest().body("Invalid multipart data");
    }
}

#[delete("/category/delete")]
async fn delete_category(
    req: HttpRequest,
    query: web::Query<QueryParams>,
    data: web::Data<AppState>,
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

    let category_id = query_params.category_id.unwrap();
    let user_id = query_params.user_id.unwrap();

    match db::delete_category_from_db(&context.conn, user_id, category_id) {
        Ok(_) => HttpResponse::NoContent().finish(),
        Err(error_message) => {
            error!("Failed to delete category from database: {}", error_message);
            HttpResponse::InternalServerError().json(json!({
                "message": error_message.to_string()
            }))
        }
    }
}
