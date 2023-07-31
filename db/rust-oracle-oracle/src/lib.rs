use oracle::{Connection, Connector};

pub fn get_connect() -> Connection {
    dotenvy::dotenv().ok();

    let dbname = std::env::var("DBNAME").expect("database name");
    let dbuser = std::env::var("DBUSER").expect("user name");
    let dbpass = std::env::var("DBPASS").expect("password");

    let conn = Connection::connect(&dbuser, &dbpass, &dbname).expect("数据库连接失败");
    conn
}

pub fn get_connector() -> Connector {
    dotenvy::dotenv().ok();

    let dbname = std::env::var("DBNAME").expect("database name");
    let dbuser = "sys";
    let dbpass = std::env::var("DBPASS_SYS").expect("password");

    let conn = Connector::new(dbuser, &dbpass, &dbname);
    conn
}
