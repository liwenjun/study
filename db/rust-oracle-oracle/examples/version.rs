use oracle::{Connection, Result, Version};
use rust_oracle_oracle::get_connect;

fn main() -> Result<()> {
    let client_ver = Version::client()?;
    println!("Oracle Client Version: {}", client_ver);

    let conn = get_connect();
    let (server_ver, banner) = conn.server_version()?;
    println!("Oracle Server Version: {}", server_ver);
    println!("--- Server Version Banner ---");
    println!("{}", banner);
    println!("-----------------------------");
    Ok(())
}
