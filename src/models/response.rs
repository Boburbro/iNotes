use std::collections::HashMap;

use actix_multipart::Multipart;
use actix_web::{
    web::{self},
    HttpRequest, HttpResponse,
};
use futures::TryStreamExt;
use log::error;
use r2d2::PooledConnection;
use r2d2_sqlite::SqliteConnectionManager;
use serde::{Deserialize, Serialize};
use serde_json::json;

use crate::state::AppState;

use super::NewNote;

const BASE_URL: &str = "http://localhost:8080";

#[derive(Deserialize, Debug, Clone)]
pub struct QueryParams {
    pub note_id: Option<u64>,
    pub page: Option<u16>,
    pub per_page: Option<u8>,
    pub category: Option<String>,
}

#[derive(Deserialize, Debug, Clone)]
pub struct PathParams {
    pub note_id: Option<u64>,
}

#[derive(Deserialize, Debug, Clone)]
pub struct JsonParams {
    pub new_note: NewNote,
}

#[derive(Deserialize)]
pub struct PaginationParams {
    pub page: Option<u32>,
    pub per_page: Option<u32>,
}

#[derive(Serialize, Deserialize, Debug)]
pub struct Link {
    pub url: Option<String>,
    pub label: String,
    pub active: bool,
}

#[derive(Serialize, Deserialize, Debug)]
pub struct Links {
    pub first: String,
    pub last: String,
    pub prev: Option<String>,
    pub next: Option<String>,
}

#[derive(Serialize, Deserialize, Debug)]
pub struct Meta {
    pub current_page: u16,
    pub from: u16,
    pub last_page: u16,
    pub path: String,
    pub per_page: u8,
    pub to: u16,
    pub total: u32,
}

#[derive(Serialize, Deserialize, Debug)]
pub struct ApiResponse<T> {
    pub data: T,
    pub links: Links,
    pub meta: Meta,
}

#[derive(Debug)]
pub struct Pagination {
    pub page: u16,
    pub per_page: u8,
    pub offset: u16,
}

pub trait ResponseBuilder<T> {
    fn build(data: T, total: u32, pagination: &Pagination) -> ApiResponse<T>;
}

impl<T: Serialize> ResponseBuilder<Vec<T>> for ApiResponse<Vec<T>> {
    fn build(data: Vec<T>, total: u32, pagination: &Pagination) -> ApiResponse<Vec<T>> {
        let last_page =
            (total as u32 + pagination.per_page as u32 - 1) / pagination.per_page as u32;
        ApiResponse {
            data: data,
            links: Links {
                first: format!("{}?page=1", BASE_URL),
                last: format!("{}?page={}", BASE_URL, last_page),
                prev: if pagination.page > 1 {
                    Some(format!("{}?page={}", BASE_URL, pagination.page - 1))
                } else {
                    None
                },
                next: if pagination.page < last_page as u16 {
                    Some(format!("{}?page={}", BASE_URL, pagination.page + 1))
                } else {
                    None
                },
            },
            meta: Meta {
                current_page: pagination.page,
                from: pagination.offset + 1,
                last_page: last_page as u16,
                path: BASE_URL.to_string(),
                per_page: pagination.per_page,
                to: (pagination.offset + pagination.per_page as u16).min(total as u16) as u16,
                total: total,
            },
        }
    }
}

pub trait PaginationHelper {
    fn to_pagination(&self) -> Pagination;
}

#[derive(Default)]
pub struct RequestContextParams {
    pub query_params: Option<QueryParams>,
    pub path_params: Option<PathParams>,
    pub json_params: Option<JsonParams>,
    pub multipart_params: Option<HashMap<String, Vec<u8>>>,
}

pub struct RequestContext {
    pub req: HttpRequest,
    pub conn: PooledConnection<SqliteConnectionManager>,
    pub params: RequestContextParams,
}

impl RequestContext {
    pub fn new(
        req: HttpRequest,
        data: &web::Data<AppState>,
        params: RequestContextParams,
    ) -> Result<Self, HttpResponse> {
        // Veritabanı bağlantısını al
        let conn = data.pool.get().map_err(|e| {
            error!("Failed to get connection from pool: {}", e);
            HttpResponse::InternalServerError().json(json!({
                "message": "Internal Server Error"
            }))
        })?;

        Ok(Self {
            req: req,
            conn: conn,
            params: params,
        })
    }

    pub async fn process_multipart(
        mut payload: Multipart,
    ) -> Result<HashMap<String, Vec<u8>>, HttpResponse> {
        let mut multipart_params = HashMap::new();

        while let Ok(Some(mut field)) = payload.try_next().await {
            let content_disposition = field.content_disposition().unwrap();
            let field_name = content_disposition.get_name().unwrap().to_string();

            let mut field_data = Vec::new();
            while let Some(chunk) = field.try_next().await.unwrap() {
                field_data.extend_from_slice(&chunk);
            }

            multipart_params.insert(field_name, field_data);
        }

        Ok(multipart_params)
    }

    pub fn pagination(&self) -> Pagination {
        if let Some(query_params) = &self.params.query_params {
            let page = query_params.page.unwrap_or(1).max(1);
            let per_page = query_params.per_page.unwrap_or(20).clamp(1, 100); // Min 1, Max 100
            let offset = (page - 1) * per_page as u16;
            Pagination {
                page,
                per_page,
                offset,
            }
        } else {
            Pagination {
                page: 1,
                per_page: 20,
                offset: 0,
            }
        }
    }
}
