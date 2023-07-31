use casper_json_rpc::{Error, Params, RequestHandlersBuilder, ReservedErrorCode};
use serde::de::DeserializeOwned;
use serde::Deserialize;
use std::sync::Arc;

async fn add(params: Option<Params>) -> Result<i64, Error> {
    let payload: [i64; 2] = from_params(params)?;
    Ok(payload[0] + payload[1])
}

#[derive(Deserialize)]
struct SubStruct {
    pub a: i64,
    pub b: i64,
}

async fn sub(params: Option<Params>) -> Result<i64, Error> {
    let payload: SubStruct = from_params(params)?;
    Ok(payload.a - payload.b)
}

#[tokio::main]
async fn main() {
    let mut handlers = RequestHandlersBuilder::new();
    handlers.register_handler("add", Arc::new(add));
    handlers.register_handler("sub", Arc::new(sub));
    let handlers = handlers.build();

    // Get the new route.
    let path = "rpc";
    let max_body_bytes = 1024;
    let allow_unknown_fields = false;
    let route = casper_json_rpc::route(path, max_body_bytes, handlers, allow_unknown_fields);

    warp::serve(route).run(([127, 0, 0, 1], 3030)).await;
}

// 辅助
pub fn from_params<T>(params: Option<Params>) -> Result<T, Error>
where
    T: DeserializeOwned,
{
    params.map_or(
        Err::<T, Error>(Error::new(ReservedErrorCode::InvalidParams, "未输入参数")),
        |x| {
            serde_json::from_value::<T>(x.into())
                .map_err(|e| Error::new(ReservedErrorCode::InternalError, e.to_string()))
        },
    )
}
