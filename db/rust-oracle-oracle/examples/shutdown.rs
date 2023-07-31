use oracle::{Connector, Privilege, Result, ShutdownMode};
use rust_oracle_oracle::get_connector;

fn main() -> Result<()> {
    let shutdown_mode = ShutdownMode::Immediate;

    // connect as sysdba or sysoper
    let conn = get_connector()
        .privilege(Privilege::Sysdba)
        .connect()?;

    // begin 'shutdown'
    conn.shutdown_database(shutdown_mode)?;

    // close the database
    conn.execute("alter database close normal", &[])?;
    println!("Database closed.");

    // dismount the database
    conn.execute("alter database dismount", &[])?;
    println!("Database dismounted.");

    // finish 'shutdown'
    conn.shutdown_database(ShutdownMode::Final)?;
    println!("ORACLE instance shut down.");
    conn.close()?;
    Ok(())
}
