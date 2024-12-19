use std::net::SocketAddr;

use lazy_static::lazy_static;
use tokio::sync::RwLock;

use super::db::Database;
use crate::gateway::handler::Gateway;

lazy_static! {
    pub static ref APP: ApplicationState = ApplicationState::new();
}

/// Contains all the application state and manages application state changes.
pub struct ApplicationState {
    pub db: RwLock<Database>,
    pub gateway: RwLock<Gateway>,
    config: Config,
}

impl ApplicationState {
    fn new() -> Self {
        ApplicationState {
            db: RwLock::new(Database::new()),
            config: Config::from_env(),
            gateway: RwLock::new(Gateway::new()),
        }
    }

    /// The application config.
    pub fn config(&self) -> &Config {
        &self.config
    }

    /// Initializes the application
    pub async fn init(&self) -> Result<(), sqlx::Error> {
        self.db.write().await.connect(self.config.database_url()).await
    }

    /// Closes the application and cleans up resources.
    pub async fn close(&self) {
        self.db.write().await.close().await
    }
}

/// Application configuration
pub struct Config {
    database_url: String,
    listen_addr: SocketAddr,
    machine_id: i32,
    process_id: i32,
    secret: String,
    client_path: String,
}

impl Config {
    /// Creates a new config instance.
    pub const fn new(
        database_url: String,
        machine_id: i32,
        process_id: i32,
        listen_addr: SocketAddr,
        secret: String,
        client_path: String,
    ) -> Self {
        Config {
            database_url,
            machine_id,
            process_id,
            listen_addr,
            secret,
            client_path,
        }
    }

    /// The client_path.
    pub fn client_path(&self) -> &str {
        &self.client_path
    }

    /// The secret.
    pub fn secret(&self) -> &str {
        &self.secret
    }

    /// The database url.
    pub fn database_url(&self) -> &str {
        &self.database_url
    }

    /// The machine id.
    pub fn machine_id(&self) -> i32 {
        self.machine_id
    }

    /// The process id.
    pub fn process_id(&self) -> i32 {
        self.process_id
    }

    /// The addres for the backend server to listen on.
    pub fn listen_addr(&self) -> SocketAddr {
        self.listen_addr
    }

    /// Creates a new config from environment variables
    ///
    /// ## Panics
    ///
    /// Panics if any of the required environment variables are not set
    /// or if they are not in a valid format.
    pub fn from_env() -> Self {
        let database_url = std::env::var("DATABASE_URL").expect("DATABASE_URL environment variable must be set");
        let machine_id = std::env::var("MACHINE_ID")
            .expect("MACHINE_ID environment variable must be set")
            .parse::<i32>()
            .expect("MACHINE_ID must be a valid integer");
        let process_id = std::env::var("PROCESS_ID")
            .expect("PROCESS_ID environment variable must be set")
            .parse::<i32>()
            .expect("PROCESS_ID must be a valid integer");
        let listen_addr = std::env::var("LISTEN_ADDR")
            .expect("LISTEN_ADDR environment variable must be set")
            .parse::<SocketAddr>()
            .expect("LISTEN_ADDR must be a valid socket address");
        let secret = std::env::var("SECRET").expect("SECRET environment variable must be set");
        let client_path = std::env::var("CLIENT_PATH").expect("CLIENT_PATH environment variable must be set");
        Config::new(database_url, machine_id, process_id, listen_addr, secret, client_path)
    }
}
