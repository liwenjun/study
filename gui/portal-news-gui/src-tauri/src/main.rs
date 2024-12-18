#![cfg_attr(
    all(not(debug_assertions), target_os = "windows"),
    windows_subsystem = "windows"
)]

#[macro_use]
extern crate magic_static;
use clap::Parser;
use seeker::{get_configuration, Settings, Record, Click};
use std::path::Path;

magic_statics! {
    pub static ref CONF:Settings = get_configuration(Path::new("conf"));
}

#[derive(Parser)]
#[clap(author = "liwenjun (liwenjun@21cn.com)")]
#[clap(version = "0.1.0")]
#[clap(name = "webseeker")]
#[clap(about, long_about = None)]
struct Cli {
    #[clap(short, long, action)]
    showconfig: bool,
}

#[magic_static::main(CONF)]
fn main() {
    let cli = Cli::parse();
    if cli.showconfig {
        println!(
            "{}",
            toml::to_string_pretty(&Settings::default()).unwrap()
        );
    } else {
        tauri::Builder::default()
            .invoke_handler(tauri::generate_handler![news, click])
            .run(tauri::generate_context!())
            .expect("error while running tauri application");
    }
}

#[tauri::command(async)]
fn news() -> Vec<Record> {
    seeker::news(&CONF.section, &CONF.click)
}

#[tauri::command(async)]
fn click(acid: usize) -> Click {
    seeker::click(acid, &CONF.click)
}
