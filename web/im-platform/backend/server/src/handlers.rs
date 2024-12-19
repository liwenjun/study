mod auth;
mod guilds;
mod users;
mod utils;

use jsonrpc::{RequestHandlers, RequestHandlersBuilder};
use std::sync::Arc;

pub fn get() -> RequestHandlers {
    let mut handlers = RequestHandlersBuilder::new();

    handlers.register_handler("users.check", Arc::new(users::check));
    handlers.register_handler("users.auth", Arc::new(users::auth));
    handlers.register_handler("users.create", Arc::new(users::create));
    handlers.register_handler("users.self", Arc::new(users::myself));
    handlers.register_handler("users.guilds", Arc::new(users::fetch_self_guilds));
    handlers.register_handler("users.update_displayname", Arc::new(users::update_display));
    handlers.register_handler("users.update_presence", Arc::new(users::update_presence));
    handlers.register_handler("users.other_guilds", Arc::new(users::fetch_other_guilds));
    handlers.register_handler("guilds.create", Arc::new(guilds::create));
    handlers.register_handler("guilds.message", Arc::new(guilds::create_message));
    handlers.register_handler("guilds.fetch", Arc::new(guilds::fetch_guild));
    handlers.register_handler("guilds.join", Arc::new(guilds::create_member));
    handlers.register_handler("guilds.leave", Arc::new(guilds::leave_guild));

    handlers.build()
}
