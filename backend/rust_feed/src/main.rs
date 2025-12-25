use actix_web::{get, web, App, HttpResponse, HttpServer, Responder};
use chrono::Utc;
use serde::Serialize;

#[derive(Serialize)]
struct HealthCheckResponse {
    status: String,
    timestamp: String,
}

#[get("/health")]
async fn health_check() -> impl Responder {
    let response = HealthCheckResponse {
        status: "ok".to_string(),
        timestamp: Utc::now().to_rfc3339(),
    };
    HttpResponse::Ok().json(response)
}

#[actix_web::main]
async fn main() -> std::io::Result<()> {
    println!("Starting Rust Feed Service on port 8081...");
    
    HttpServer::new(|| {
        App::new()
            .service(health_check)
    })
    .bind(("0.0.0.0", 8081))?
    .run()
    .await
}