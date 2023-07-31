use oracle::{Connector, Privilege, Result};
use rust_oracle_oracle::get_connector;

fn main() -> Result<()> {
    // connect as sysdba or sysoper with prelim_auth mode
    let conn = get_connector()
        .privilege(Privilege::Sysdba)
        .prelim_auth(true)
        .connect()?;

    // start up database. The database is not mounted at this time.
    conn.startup_database(&[])?;
    conn.close()?;

    // connect as sysdba or sysoper **without** prelim_auth mode
    let conn = get_connector()
        .privilege(Privilege::Sysdba)
        .connect()?;

    // mount and open the database
    conn.execute("alter database mount", &[])?;
    println!("Database mounted.");
    conn.execute("alter database open", &[])?;
    println!("Database opened.");
    conn.close()?;
    Ok(())
}
