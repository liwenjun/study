use crate::dispatch;
use crate::handlers::auth::{generate_hash, validate_credentials};
use crate::handlers::utils::{from_auth, from_params};
use crate::models::{
    appstate::APP,
    auth::{StoredCredentials, Token},
    gateway_event::{GatewayEvent, PresenceUpdatePayload},
    guild::Guild,
    rpc::CreateUser,
    snowflake::Snowflake,
    user::{Presence, User},
};
use jsonrpc::{Error, Params, ReservedErrorCode};
use secrecy::ExposeSecret;
use serde::Serialize;

/// 登录返回信息
#[derive(Serialize, Debug)]
pub struct UT {
    user_id: Snowflake,
    token: String,
}

/// 检查用户是否存在
pub async fn check(params: Option<Params>, _auth: Option<String>) -> Result<bool, Error> {
    let payload: [String; 1] = from_params(params)?;
    let username = &payload[0];
    let db = &APP.db.read().await;

    match sqlx::query!("SELECT id FROM users WHERE username = $1", username)
        .fetch_one(db.pool())
        .await
    {
        Ok(_) => Ok(true),
        Err(sqlx::Error::RowNotFound) => Ok(false),
        Err(e) => Err(Error::new(ReservedErrorCode::InternalError, e.to_string())),
    }
}


/// 登录
pub async fn auth(params: Option<Params>, _auth: Option<String>) -> Result<UT, Error> {
    let payload = from_params(params)?;

    let user_id = validate_credentials(payload)
        .await
        .map_err(|e| Error::new(ReservedErrorCode::InternalError, e.to_string()))?;

    let token = Token::new_for(user_id).map_err(|e| Error::new(ReservedErrorCode::InternalError, e.to_string()))?;

    Ok(UT {
        user_id,
        token: token.expose_secret().clone(),
    })
}


/// 创建用户
pub async fn create(params: Option<Params>, _auth: Option<String>) -> Result<User, Error> {
    let payload: CreateUser = from_params(params)?;
    let password = payload.password.clone();

    let user = User::from_payload(payload)
        .await
        .map_err(|e| Error::new(ReservedErrorCode::InternalError, e.to_string()))?;

    if User::fetch_by_username(user.username()).await.is_some() {
        tracing::debug!("User with username {} already exists", user.username());
        return Err(Error::new(
            ReservedErrorCode::InternalError,
            format!("User with username {} already exists", user.username()),
        ));
    }

    let credentials = StoredCredentials::new(
        user.id(),
        generate_hash(&password).map_err(|e| Error::new(ReservedErrorCode::InternalError, e.to_string()))?,
    );

    // User needs to be committed before credentials to avoid foreign key constraint
    if let Err(e) = user.commit().await {
        tracing::error!("Failed to commit user to database: {}", e);
        return Err(Error::new(ReservedErrorCode::InternalError, e.to_string()));
    } else if let Err(e) = credentials.commit().await {
        tracing::error!("Failed to commit credentials to database: {}", e);
        return Err(Error::new(ReservedErrorCode::InternalError, e.to_string()));
    }

    Ok(user)
}


/// 获取用户自身信息
pub async fn myself(_params: Option<Params>, auth: Option<String>) -> Result<User, Error> {
    let token = from_auth(auth).await?;

    User::fetch(token.data().user_id()).await.ok_or(Error::new(
        ReservedErrorCode::InternalError,
        "Failed to fetch user from database",
    ))
}


/// 获取用户加入的群组
pub async fn fetch_self_guilds(_params: Option<Params>, auth: Option<String>) -> Result<Vec<Guild>, Error> {
    let token = from_auth(auth).await?;
    let guilds = Guild::fetch_all_for_user(token.data().user_id()).await.map_err(|e| {
        tracing::error!(message = "Failed to fetch user guilds from database", user = %token.data().user_id(), error = %e);
        Error::new(ReservedErrorCode::InternalError, e.to_string())
    })?;

    Ok(guilds)
}

/// 获取用户未加入的群组
pub async fn fetch_other_guilds(_params: Option<Params>, auth: Option<String>) -> Result<Vec<Guild>, Error> {
    let token = from_auth(auth).await?;
    let guilds = Guild::fetch_others_for_user(token.data().user_id()).await.map_err(|e| {
        tracing::error!(message = "Failed to fetch user guilds from database", user = %token.data().user_id(), error = %e);
        Error::new(ReservedErrorCode::InternalError, e.to_string())
    })?;

    Ok(guilds)
}

/// 更新用户在线状态
pub async fn update_presence(params: Option<Params>, auth: Option<String>) -> Result<Presence, Error> {
    //(token: Token, new_presence: Presence) -> Result<impl warp::Reply, warp::Rejection> {
    let payload: [Presence; 1] = from_params(params)?;
    let token = from_auth(auth).await?;

    let new_presence = payload[0];
    let user_id_i64: i64 = token.data().user_id().into();
    let db = &APP.db.read().await;

    sqlx::query!(
        "UPDATE users SET last_presence = $1 WHERE id = $2",
        new_presence as i16,
        user_id_i64
    )
    .execute(db.pool())
    .await
    .map_err(|e| {
        tracing::error!(message = "Failed to update user presence", user = %token.data().user_id(), error = %e);
        Error::new(ReservedErrorCode::InternalError, e.to_string())
    })?;

    if APP.gateway.read().await.is_connected(token.data().user_id()) {
        dispatch!(GatewayEvent::PresenceUpdate(PresenceUpdatePayload {
            presence: new_presence,
            user_id: token.data().user_id(),
        }));
    }

    Ok(new_presence)
}


/// 更新用户显示名
pub async fn update_display(params: Option<Params>, auth: Option<String>) -> Result<String, Error> {
    //pub async fn update_display(token: Token, new_name: String) -> Result<impl warp::Reply, warp::Rejection> {
    let payload: [String; 1] = from_params(params)?;
    let token = from_auth(auth).await?;

    let new_name = &payload[0];
    let user_id_i64: i64 = token.data().user_id().into();
    let db = &APP.db.read().await;

    sqlx::query!(
        "UPDATE users SET display_name = $1 WHERE id = $2",
        new_name,
        user_id_i64
    )
    .execute(db.pool())
    .await
    .map_err(|e| {
        tracing::error!(message = "Failed to update user display_name", user = %token.data().user_id(), error = %e);
        Error::new(ReservedErrorCode::InternalError, e.to_string())
    })?;
    /*
        if APP.gateway.read().await.is_connected(token.data().user_id()) {
            dispatch!(GatewayEvent::PresenceUpdate(PresenceUpdatePayload {
                presence: new_presence,
                user_id: token.data().user_id(),
            }));
        }
    */
    Ok(new_name.to_string())
}
