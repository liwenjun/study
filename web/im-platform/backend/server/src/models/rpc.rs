use crate::models::snowflake::Snowflake;
use secrecy::Secret;
use serde::{Deserialize, Serialize};

/// A request to create a new user
#[derive(Deserialize, Debug, Clone)]
pub struct CreateUser {
    pub username: String,
    pub password: Secret<String>,
}

/// A request to create a new message
///
/// A Message object is returned on success
#[derive(Serialize, Deserialize, Debug, Clone)]
pub struct CreateMessage {
    guild_id: Snowflake,
    content: String,
    nonce: Option<String>,
}

impl CreateMessage {
    pub fn new(guild_id: Snowflake, content: String, nonce: Option<String>) -> Self {
        CreateMessage {
            guild_id,
            content,
            nonce,
        }
    }

    pub fn content(&self) -> &str {
        &self.content
    }

    pub fn nonce(&self) -> &Option<String> {
        &self.nonce
    }

    pub fn guild_id(&self) -> &Snowflake {
        &self.guild_id
    }
}

#[derive(Deserialize, Debug, Clone)]
pub struct CreateGuild {
    pub name: String,
}

#[derive(Deserialize, Debug, Clone)]
#[serde(tag = "type", rename_all = "SCREAMING_SNAKE_CASE")]
pub enum CreateChannel {
    GuildText { name: String },
}
