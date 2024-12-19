use core::fmt::Debug;

use chrono::prelude::*;
use jsonwebtoken::{decode, encode, DecodingKey, EncodingKey, Header, Validation};
use secrecy::{ExposeSecret, Secret};
use serde::{Deserialize, Serialize};

use super::{appstate::APP, snowflake::Snowflake};

#[derive(Serialize, Deserialize, Debug, Clone)]
pub struct TokenData {
    /// The user id of the token owner
    user_id: Snowflake,
    /// The expiration time of the token in seconds
    /// Note: This field is validated by the jsonwebtoken crate
    exp: usize,
    /// Issued at time of the token in seconds
    /// Note: This field is validated by the jsonwebtoken crate
    iat: usize,
}

impl TokenData {
    /// Create a new token data struct with the given user id and iat
    ///
    /// # Arguments
    ///
    /// * `user_id` - The user id to store in the token
    /// * `iat` - The issuer time of the token
    pub fn new(user_id: Snowflake, iat: usize) -> Self {
        TokenData {
            user_id,
            iat,
            exp: Utc::now().timestamp() as usize + 86400,
        }
    }

    /// Returns the user id of the token owner
    pub fn user_id(&self) -> Snowflake {
        self.user_id
    }

    /// Returns the issuer time of the token
    pub fn iat(&self) -> usize {
        self.iat
    }

    /// Returns the expiration time of the token
    pub fn exp(&self) -> usize {
        self.exp
    }
}

/// Represents a JWT used for authentication
#[derive(Clone)]
pub struct Token {
    /// The data stored in the token
    data: TokenData,
    /// The token string
    token: Secret<String>,
}

impl Token {
    /// Generate a new token with the given data
    ///
    /// # Arguments
    ///
    /// * `data` - The data to store in the token
    /// * `secret` - The secret to sign the token with
    ///
    /// # Errors
    ///
    /// Returns an error if the token could not be generated or contains invalid data.
    // pub fn new(data: &TokenData, secret: &str) -> Result<Self, jsonwebtoken::errors::Error> {
    pub fn new(data: &TokenData) -> Result<Self, jsonwebtoken::errors::Error> {
        Ok(Token {
            data: data.clone(),
            token: Secret::new(encode(
                &Header::default(),
                &data,
                &EncodingKey::from_secret(APP.config().secret().as_ref()),
            )?),
        })
    }

    /// Generate a new token for the given user, with the current time as the issue time.
    ///
    /// # Arguments
    ///
    /// * `user_id` - The id of the user to generate the token for
    /// * `secret` - The secret to sign the token with
    ///
    /// # Errors
    ///
    /// Returns an error if the token could not be generated or contains invalid data.
    // pub fn new_for(user_id: Snowflake, secret: &str) -> Result<Self, jsonwebtoken::errors::Error> {
    pub fn new_for(user_id: Snowflake) -> Result<Self, jsonwebtoken::errors::Error> {
        Self::new(&TokenData::new(user_id, Utc::now().timestamp() as usize))
    }

    /// Decode an existing token and return it. This will not validate the token.
    ///
    /// # Arguments
    ///
    /// * `token` - The token to decode
    /// * `secret` - The secret to decode the token with
    ///
    /// # Errors
    ///
    /// Returns an error if the token could not be decoded or the secret was invalid.
    // fn decode(token: &str, secret: &str) -> Result<Self, jsonwebtoken::errors::Error> {
    fn decode(token: &str) -> Result<Self, jsonwebtoken::errors::Error> {
        let decoded = decode::<TokenData>(
            token,
            &DecodingKey::from_secret(APP.config().secret().as_ref()),
            &Validation::default(),
        )?;
        Ok(Token {
            data: decoded.claims,
            token: Secret::new(token.to_string()),
        })
    }

    /// Decode and validate an existing token and return it.
    ///
    /// # Arguments
    ///
    /// * `token` - The token to decode
    /// * `secret` - The secret to decode the token with
    ///
    /// # Errors
    ///
    /// Returns an error if the token could not be decoded or the secret was invalid.
    /// Returns an error if the token was issued before the last password change.
    // pub async fn validate(token: &str, secret: &str) -> Result<Self, anyhow::Error> {
    pub async fn validate(token: &str) -> Result<Self, anyhow::Error> {
        let token = Self::decode(token)?;
        let stored_creds = StoredCredentials::fetch(token.data().user_id())
            .await
            .ok_or(anyhow::anyhow!("User credentials not found"))?;
        // Check that the token's iat is after the last changed time of the stored credentials
        if token.data().iat() < stored_creds.last_changed.timestamp() as usize {
            return Err(anyhow::anyhow!("Token issued before last password change"));
        }
        Ok(token)
    }

    /// Returns the token data
    pub fn data(&self) -> &TokenData {
        &self.data
    }
}

impl ExposeSecret<String> for Token {
    fn expose_secret(&self) -> &String {
        self.token.expose_secret()
    }
}

impl Debug for Token {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        f.debug_struct("Token")
            .field("data", &self.data)
            .field("token", &"**********")
            .finish()
    }
}

/// An incoming set of credentials.
#[derive(Deserialize, Debug, Clone)]
pub struct Credentials {
    username: String,
    password: Secret<String>,
}

impl Credentials {
    pub fn new(username: String, password: String) -> Self {
        Credentials {
            username,
            password: Secret::new(password),
        }
    }

    pub fn username(&self) -> &str {
        &self.username
    }

    pub fn password(&self) -> &Secret<String> {
        &self.password
    }
}

pub struct StoredCredentials {
    user_id: Snowflake,
    hash: Secret<String>,
    last_changed: DateTime<Utc>,
}

impl StoredCredentials {
    /// Create a new set of stored credentials.
    pub fn new(user_id: Snowflake, hash: String) -> Self {
        StoredCredentials {
            user_id,
            hash: Secret::new(hash),
            last_changed: Utc::now(),
        }
    }

    /// The user id of the user that owns the credentials.
    pub fn user_id(&self) -> Snowflake {
        self.user_id
    }

    /// The hashed password stored in PHC string format.
    pub fn hash(&self) -> &Secret<String> {
        &self.hash
    }

    pub async fn fetch(id: Snowflake) -> Option<StoredCredentials> {
        let db = &APP.db.read().await;
        let user_id: i64 = id.into();

        let result = sqlx::query!(
            "SELECT user_id, password, last_changed
            FROM secrets
            WHERE user_id = $1",
            user_id
        )
        .fetch_optional(db.pool())
        .await
        .ok()??;

        Some(Self {
            user_id: result.user_id.try_into().expect("user_id is negative for some reason"),
            hash: Secret::new(result.password),
            last_changed: DateTime::from_utc(NaiveDateTime::from_timestamp_opt(result.last_changed, 0).unwrap(), Utc),
        })
    }

    /// Fetch a set of credentials from the database.
    ///
    /// # Arguments
    ///
    /// * `username` - The username to fetch credentials for.
    ///
    /// # Returns
    ///
    /// * `Option<StoredCredentials>` - The credentials if they exist.
    pub async fn fetch_by_username(username: String) -> Option<StoredCredentials> {
        let db = &APP.db.read().await;

        let result = sqlx::query!(
            "SELECT users.id, secrets.password, secrets.last_changed
            FROM users JOIN secrets ON users.id = secrets.user_id
            WHERE users.username = $1",
            username
        )
        .fetch_optional(db.pool())
        .await
        .ok()??;

        Some(Self {
            user_id: result.id.try_into().expect("user_id is negative for some reason"),
            hash: Secret::new(result.password),
            last_changed: DateTime::from_utc(NaiveDateTime::from_timestamp_opt(result.last_changed, 0).unwrap(), Utc),
        })
    }

    /// Commit the credentials to the database.
    ///
    /// # Errors
    ///
    /// Returns an error if the credentials could not be committed,
    /// this could be due to the user not existing in the database.
    pub async fn commit(&self) -> Result<(), sqlx::Error> {
        let db = &APP.db.read().await;
        let user_id: i64 = self.user_id.into();

        sqlx::query!(
            "INSERT INTO secrets (user_id, password, last_changed) VALUES ($1, $2, $3)
            ON CONFLICT (user_id) DO UPDATE SET password = $2, last_changed = $3",
            user_id,
            self.hash.expose_secret(),
            self.last_changed.timestamp()
        )
        .execute(db.pool())
        .await?;

        Ok(())
    }

    /// Update the password hash of the credentials, changing the last changed field with it.
    pub async fn update_hash(&mut self, new_hash: Secret<String>) {
        self.hash = new_hash;
        self.last_changed = Utc::now();
    }
}
