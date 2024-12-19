use postgrest::Postgrest;

const ENDPOINT: &str = "http://localhost:3000";
const TOKEN: &str = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJyb2xlIjoidG9kb191c2VyIn0.gUOKnMS0wLW9iFArQcmJKiWQMNOw28x6zy33UsfBG28";

#[tokio::main]
async fn main() -> Result<(), Box<dyn std::error::Error>> {
    let client = Postgrest::new(ENDPOINT); //.insert_header("Content-Type", "text/csv");

    show(&client).await;
    auth(&client).await;
    filter(&client).await;
    update(&client).await;
    // insert(&client).await;
    upsert(&client).await;
    Ok(())
}

async fn show(client: &Postgrest) -> Result<(), Box<dyn std::error::Error>> {
    let resp = client.from("todos").select("*").execute().await?;
    println!("show: {}", resp.text().await?);
    Ok(())
}

async fn auth(client: &Postgrest) -> Result<(), Box<dyn std::error::Error>> {
    let resp = client
        .from("todos")
        .auth(TOKEN)
        .select("*")
        .execute()
        .await?;
    let body = resp.text().await?;
    println!("auth: {}", body);
    Ok(())
}

async fn filter(client: &Postgrest) -> Result<(), Box<dyn std::error::Error>> {
    let resp = client
        .from("todos")
        .eq("id", "1")
        .select("*")
        .execute()
        .await?;
    println!("filter: {}", resp.text().await?);
    Ok(())
}

async fn update(client: &Postgrest) -> Result<(), Box<dyn std::error::Error>> {
    let resp = client
        .from("todos")
        .auth(TOKEN)
        .eq("id", "1")
        .update("{\"due\": \"now\"}")
        .execute()
        .await?;
    println!("update: {}", resp.text().await?);
    Ok(())
}

async fn insert(client: &Postgrest) -> Result<(), Box<dyn std::error::Error>> {
    let resp = client
        .from("todos")
        .auth(TOKEN)
        //.eq("id", "1")
        .insert(
            r#"[{ "task": "soedirgo", "done": "false" },
                { "task": "jose", "done": "true" }]"#,
        )
        .execute()
        .await?;
    println!("insert: {}", resp.text().await?);
    Ok(())
}

async fn upsert(client: &Postgrest) -> Result<(), Box<dyn std::error::Error>> {
    let resp = client
        .from("todos")
        .auth(TOKEN)
        //.eq("id", "1")
        .upsert(
            r#"[{ "task": "soedirgo", "done": "true", "due": "now" },
                { "task": "新增任务2", "done": "false", "due": "now" }]"#,
        )
        .on_conflict("task")
        .execute()
        .await?;
    println!("upsert: {}", resp.text().await?);
    Ok(())
}
