use oracle::{Connection, Result};
use rust_oracle_oracle::get_connect;

// Select a table and print column types and values as CSV.
// The CSV format isn't valid if data include double quotation
// marks, commas or return codes.
fn main() -> Result<()> {
    let sql = "select * from HR.EMPLOYEES";
    let conn = get_connect();
    let mut stmt = conn.statement(sql).build()?;
    let rows = stmt.query(&[])?;

    // print column types
    for (idx, info) in rows.column_info().iter().enumerate() {
        if idx != 0 {
            print!(",");
        }
        print!("{}", info);
    }
    println!();

    for row_result in rows {
        // print column values
        for (idx, val) in row_result?.sql_values().iter().enumerate() {
            if idx != 0 {
                print!(",");
            }
            print!("{}", val);
        }
        println!();
    }
    Ok(())
}
