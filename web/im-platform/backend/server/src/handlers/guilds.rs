use crate::dispatch;
use crate::handlers::utils::{from_auth, from_params};
use crate::models::{
    appstate::APP,
    gateway_event::{GatewayEvent, GuildCreatePayload},
    guild::Guild,
    member::{Member, UserLike},
    message::Message,
    rpc::CreateMessage,
    snowflake::Snowflake,
};
use jsonrpc::{Error, Params, ReservedErrorCode};


/// 发送消息
pub async fn create_message(params: Option<Params>, auth: Option<String>) -> Result<Message, Error> {
    let token = from_auth(auth).await?;
    let payload: CreateMessage = from_params(params)?;

    let guild_id = payload.guild_id().clone();

    let member = Member::fetch(token.data().user_id(), guild_id).await.ok_or(Error::new(
        ReservedErrorCode::InternalError,
        "Not permitted to access resource.",
    ))?;

    let message = Message::from_payload(UserLike::Member(member), payload).await;

    if let Err(e) = message.commit().await {
        tracing::error!("Failed to commit message to database: {}", e);
        return Err(Error::new(
            ReservedErrorCode::InternalError,
            "Failed to commit message to database",
        ));
    }

    dispatch!(GatewayEvent::MessageCreate(message.clone()));
    Ok(message)
}

/// 创建群组
pub async fn create(params: Option<Params>, auth: Option<String>) -> Result<Guild, Error> {
    let token = from_auth(auth).await?;
    let payload = from_params(params)?;

    let guild = Guild::from_payload(payload, token.data().user_id()).await;

    if let Err(e) = guild.commit().await {
        tracing::error!("Failed to commit guild to database: {}", e);
        return Err(Error::new(ReservedErrorCode::InternalError, e.to_string()));
    }

    if let Err(e) = guild.create_member(token.data().user_id()).await {
        tracing::error!("Failed to add guild owner to guild: {}", e);
        return Err(Error::new(ReservedErrorCode::InternalError, e.to_string()));
    }

    let member = Member::fetch(token.data().user_id(), guild.id())
        .await
        .expect("Member should have been created");

    APP.gateway.write().await.add_member(token.data().user_id(), guild.id());

    dispatch!(GatewayEvent::GuildCreate(GuildCreatePayload::new(
        guild.clone(),
        vec![member.clone()]
    )));

    Ok(guild)
}


pub async fn fetch_guild(params: Option<Params>, auth: Option<String>) -> Result<Guild, Error> {
    let token = from_auth(auth).await?;
    let payload: [Snowflake; 1] = from_params(params)?;

    //tracing::debug!(token=?token);
    let guild_id = payload[0];
    Member::fetch(token.data().user_id(), guild_id).await.ok_or(Error::new(
        ReservedErrorCode::InternalError,
        "You are not a member of this guild.",
    ))?;

    let guild = Guild::fetch(guild_id).await.ok_or_else(|| {
        tracing::error!("Failed to fetch guild from database");
        Error::new(ReservedErrorCode::InternalError, "Failed to fetch guild from database")
    })?;

    Ok(guild)
}


/// 创建群组成员
pub async fn create_member(params: Option<Params>, auth: Option<String>) -> Result<Member, Error> {
    let token = from_auth(auth).await?;
    let payload: [Snowflake; 1] = from_params(params)?;

    let guild_id = payload[0];
    let guild = Guild::fetch(guild_id)
        .await
        .ok_or(Error::new(ReservedErrorCode::InternalError, "记录不存在"))?;
    if let Err(e) = guild.create_member(token.data().user_id()).await {
        tracing::error!(message = "Failed to add user to guild", user = %token.data().user_id(), guild = %guild_id, error = %e);
        return Err(Error::new(ReservedErrorCode::InternalError, e.to_string()));
    }

    let member = Member::fetch(token.data().user_id(), guild_id)
        .await
        .expect("A member should have been created");

    // Create payload seperately as it needs read access to gateway
    let gc_payload = GatewayEvent::GuildCreate(
        GuildCreatePayload::from_guild(guild)
            .await
            .map_err(|e| Error::new(ReservedErrorCode::InternalError, e.to_string()))?,
    );

    // Send GUILD_CREATE to the user who joined
    APP.gateway.write().await.send_to(member.user().id(), gc_payload);

    // Add the member to the gateway's cache
    APP.gateway.write().await.add_member(member.user().id(), guild_id);

    // Dispatch the member create event to all guild members
    dispatch!(GatewayEvent::MemberCreate(member.clone()));

    Ok(member)
}

/// 退群
pub async fn leave_guild(params: Option<Params>, auth: Option<String>) -> Result<Guild, Error> {
    let token = from_auth(auth).await?;
    let payload: [Snowflake; 1] = from_params(params)?;
    let guild_id = payload[0];

    //async fn leave_guild(guild_id: Snowflake, token: Token) -> Result<impl warp::Reply, warp::Rejection> {
    let guild = Guild::fetch(guild_id)
        .await
        .ok_or(Error::new(ReservedErrorCode::InternalError, "记录不存在"))?;
    let guild_clone = guild.clone();
    let member = Member::fetch(token.data().user_id(), guild_id)
        .await
        .ok_or(Error::new(ReservedErrorCode::InternalError, "记录不存在"))?;

    if member.user().id() == guild.owner_id() {
        return Err(Error::new(ReservedErrorCode::InternalError, "群主不能退出自己建的群"));
    }

    if let Err(e) = guild.remove_member(token.data().user_id()).await {
        tracing::error!(message = "Failed to remove user from guild", user = %token.data().user_id(), guild = %guild_id, error = %e);
        return Err(Error::new(ReservedErrorCode::InternalError, e.to_string()));
    }

    // Remove the member from the gateway's cache
    APP.gateway
        .write()
        .await
        .remove_member(token.data().user_id(), guild_id);
    // Dispatch the member remove event
    dispatch!(GatewayEvent::MemberRemove(member.clone()));

    // Send GUILD_REMOVE to the user who left
    APP.gateway
        .write()
        .await
        .send_to(member.user().id(), GatewayEvent::GuildRemove(guild));

    Ok(guild_clone)
}

/*
/// Fetch a member's data.
///
/// ## Arguments
///
/// * `token` - The user's session token, already validated
/// * `guild_id` - The ID of the guild the member is in
///
/// ## Returns
///
/// * [`Member`] - A JSON response containing the fetched [`Member`] object
///
/// ## Endpoint
///
/// GET `/guilds/{guild_id}/members/{member_id}`
async fn fetch_member(
    guild_id: Snowflake,
    member_id: Snowflake,
    token: Token,
) -> Result<impl warp::Reply, warp::Rejection> {
    // Check if the user is in the channel's guild
    Member::fetch(token.data().user_id(), guild_id)
        .await
        .or_reject(Forbidden::new("Not permitted to view resource"))?;

    let member = Member::fetch(member_id, guild_id)
        .await
        .or_reject(NotFound::new("Member does not exist or is not available."))?;

    Ok(warp::reply::with_status(
        warp::reply::json(&member),
        warp::http::StatusCode::OK,
    ))
}

/// Fetch the current user's member data.
///
/// ## Arguments
///
/// * `token` - The user's session token, already validated
/// * `guild_id` - The ID of the guild the member is in
///
/// ## Returns
///
/// * [`Member`] - A JSON response containing the fetched [`Member`] object
///
/// ## Endpoint
///
/// GET `/guilds/{guild_id}/members/@self`
async fn fetch_member_self(guild_id: Snowflake, token: Token) -> Result<impl warp::Reply, warp::Rejection> {
    let member = Member::fetch(token.data().user_id(), guild_id)
        .await
        .ok_or_else(|| warp::reject::custom(BadRequest::new("Member does not exist or is not available.")))?;

    Ok(warp::reply::with_status(
        warp::reply::json(&member),
        warp::http::StatusCode::OK,
    ))
}


*/
