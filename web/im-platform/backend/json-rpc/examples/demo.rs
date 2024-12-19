use jsonrpc::{Error, Params, RequestHandlersBuilder};
use std::{convert::Infallible, sync::Arc};

async fn get(params: Option<Params>, auth:Option<String>) -> Result<String, Error> {
    // * parse params or return `ReservedErrorCode::InvalidParams` error
    // * handle request and return result
    Ok("got it".to_string())
}

async fn put(params: Option<Params>, auth:Option<String>, other_input: &str) -> Result<String, Error> {
    Ok(other_input.to_string())
}

#[tokio::main]
async fn main() {
    // Register handlers for methods "get" and "put".
    let mut handlers = RequestHandlersBuilder::new();
    handlers.register_handler("get", Arc::new(get));
    let put_handler = move |params, auth| async move { put(params, auth, "other input").await };
    handlers.register_handler("put", Arc::new(put_handler));
    let handlers = handlers.build();

    // Get the new route.
    let path = "api";
    let max_body_bytes = 1024;
    let allow_unknown_fields = false;
    let route = jsonrpc::route(path, max_body_bytes, handlers, allow_unknown_fields);

    warp::serve(route)
        .run(([127, 0, 0, 1], 3030))
        .await;
}