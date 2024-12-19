use std::collections::hash_map::DefaultHasher;
use std::hash::{Hash, Hasher};

use chrono::Utc;
use serde::{Deserialize, Serialize};

use super::appstate::APP;

use super::{snowflake::Snowflake, user::User};

/// Represents a guild member record stored in the database.
pub struct MemberRecord {
    pub user_id: i64,
    pub guild_id: i64,
    pub joined_at: i64,
}

#[derive(Serialize, Deserialize, Debug, Clone)]
pub struct Member {
    /// The user this guild member represents
    user: User,
    /// The id of the guild this member is in
    guild_id: Snowflake,
    /// UNIX timestmap of when the user joined the guild
    joined_at: i64,
    /// Used to check if the user was mutated and needs re-committing when calling commit()
    #[serde(skip)]
    _user_hash: u64,
}

impl Member {
    /// Create a new member with the given user, guild id, and joined at timestamp.
    pub fn new(user: User, guild_id: Snowflake, joined_at: i64) -> Self {
        let mut hasher = DefaultHasher::new();
        user.hash(&mut hasher);
        let _user_hash = hasher.finish();
        Member {
            user,
            guild_id,
            joined_at,
            _user_hash,
        }
    }

    /// The user this guild member represents
    pub fn user(&self) -> &User {
        &self.user
    }

    /// The id of the guild this member is in
    pub fn guild_id(&self) -> Snowflake {
        self.guild_id
    }

    /// UNIX timestmap of when the user joined the guild
    pub fn joined_at(&self) -> i64 {
        self.joined_at
    }

    /// Mutable handle to the user this guild member represents
    pub fn user_mut(&mut self) -> &mut User {
        &mut self.user
    }

    /// Build a member object directly from a database record.
    pub async fn from_record(record: MemberRecord) -> Self {
        Self::new(
            User::fetch(record.user_id.into()).await.unwrap(),
            record.guild_id.into(),
            record.joined_at,
        )
    }

    /// Convert a user into a member with the given guild id.
    pub async fn from_user(user: User, guild_id: Snowflake) -> Self {
        Self::new(user, guild_id, Utc::now().timestamp())
    }

    /// Include the user's presence field in the member payload.
    ///
    /// ## Locks
    ///
    /// * `APP.gateway` (read)
    pub async fn include_presence(self) -> Self {
        let user = self.user.include_presence().await;
        Self { user, ..self }
    }

    /// Fetch a member from the database by id and guild id.
    pub async fn fetch(id: Snowflake, guild_id: Snowflake) -> Option<Self> {
        let db = &APP.db.read().await;
        let id_64: i64 = id.into();
        let guild_id_64: i64 = guild_id.into();

        let record = sqlx::query_as!(
            MemberRecord,
            "SELECT * FROM members WHERE user_id = $1 AND guild_id = $2",
            id_64,
            guild_id_64
        )
        .fetch_optional(db.pool())
        .await
        .ok()??;

        Some(Self::from_record(record).await)
    }

    /// Commit the member to the database.
    pub async fn commit(&self) -> Result<(), sqlx::Error> {
        let db = &APP.db.read().await;
        let id_64: i64 = self.user.id().into();
        let guild_id_64: i64 = self.guild_id.into();
        sqlx::query!(
            "INSERT INTO members (user_id, guild_id, joined_at)
            VALUES ($1, $2, $3)
            ON CONFLICT (user_id, guild_id) DO UPDATE
            SET joined_at = $3",
            id_64,
            guild_id_64,
            self.joined_at
        )
        .execute(db.pool())
        .await?;

        let mut hasher = DefaultHasher::new();
        self.user.hash(&mut hasher);
        let _current_hash = hasher.finish();

        if _current_hash != self._user_hash {
            self.user.commit().await?;
        }

        Ok(())
    }
}

/// A user or member, depending on the context.
#[derive(Serialize, Deserialize, Debug, Clone)]
#[serde(untagged)]
pub enum UserLike {
    Member(Member),
    User(User),
}

impl UserLike {
    pub fn id(&self) -> Snowflake {
        match self {
            UserLike::Member(member) => member.user.id(),
            UserLike::User(user) => user.id(),
        }
    }
}
