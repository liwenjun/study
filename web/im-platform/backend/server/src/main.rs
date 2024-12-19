mod gateway;
mod handlers;
mod macros;
mod models;

use models::appstate::APP;
use std::process::ExitCode;
use tokio::signal::ctrl_c;
use tracing_subscriber::EnvFilter;
use warp::{filters::BoxedFilter, Filter};

#[cfg(unix)]
use tokio::signal::unix::{signal, SignalKind};

#[cfg(unix)]
async fn handle_signals() {
    let mut sigterm =
        signal(SignalKind::terminate()).expect("Failed to create SIGTERM signal listener");

    tokio::select! {
        _ = sigterm.recv() => {
            tracing::info!("Received SIGTERM, terminating...");
        }
        _ = ctrl_c() => {
            tracing::info!("Received keyboard interrupt, terminating...");
        }
    };
}

#[cfg(not(unix))]
async fn handle_signals() {
    ctrl_c()
        .await
        .expect("Failed to create CTRL+C signal listener");
}

#[tokio::main]
async fn main() -> ExitCode {
    dotenv::dotenv().ok();

    let subscriber = tracing_subscriber::fmt()
        .with_env_filter(EnvFilter::from_default_env())
        .compact()
        //.with_target(false)
        .without_time()
        .finish();

    /* console_subscriber::init(); */
    tracing::subscriber::set_global_default(subscriber).expect("Failed to set subscriber");

    let gateway_routes = gateway::handler::get_routes();
    let route = jsonrpc::route("api", 1024 * 16, handlers::get(), false);

    // Initialize the database
    if let Err(e) = APP.init().await {
        tracing::error!(message = "Failed initializing application", error = %e);
        return ExitCode::FAILURE;
    }

    tokio::select!(
        _ = handle_signals() => {},
        _ = warp::serve(spa().or(gateway_routes).or(route)).run(APP.config().listen_addr()) => {}
    );
    APP.close().await;

    ExitCode::SUCCESS
}

/// SPA Home
fn spa() -> BoxedFilter<(impl warp::Reply,)> {
    warp::get()
        .and(warp::fs::dir("frontend/client/dist"))
        .boxed()
}
