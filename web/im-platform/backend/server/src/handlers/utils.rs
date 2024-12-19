use crate::models::auth::Token;
use jsonrpc::{Error, Params, ReservedErrorCode};
use serde::de::DeserializeOwned;

/// 获取参数，转换为具体类型
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

/// 获取认证信息，转换为Token
pub async fn from_auth(auth: Option<String>) -> Result<Token, Error> {
    match auth {
        None => Err(Error::new(ReservedErrorCode::InvalidRequest, "未授权访问")),
        Some(token) => match Token::validate(&token).await {
            Ok(t) => Ok(t),
            Err(e) => Err(Error::new(ReservedErrorCode::InternalError, e.to_string())),
        },
    }
}
