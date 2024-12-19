# 交流平台管理客户端

基于 `Tauri` 开发实现，使用了 [`websocket`](https://github.com/tauri-apps/plugins-workspace/tree/v1/plugins/websocket) 插件。

## websocket插件说明

### Install

This plugin requires a Rust version of at least 1.64

There are three general methods of installation that we can recommend.

Use crates.io and npm (easiest, and requires you to trust that our publishing pipeline worked)
Pull sources directly from Github using git tags / revision hashes (most secure)
Git submodule install this repo in your tauri project and then use file protocol to ingest the source (most secure, but inconvenient to use)
Install the Core plugin by adding the following to your Cargo.toml file:

`src-tauri/Cargo.toml`

```
[dependencies]
tauri-plugin-websocket = { git = "https://github.com/tauri-apps/plugins-workspace", branch = "v1" }
```

You can install the JavaScript Guest bindings using your preferred JavaScript package manager:

Note: Since most JavaScript package managers are unable to install packages from git monorepos we provide read-only mirrors of each plugin. This makes installation option 2 more ergonomic to use.

```bash
pnpm add https://github.com/tauri-apps/tauri-plugin-websocket#v1
# or
npm add https://github.com/tauri-apps/tauri-plugin-websocket#v1
# or
yarn add https://github.com/tauri-apps/tauri-plugin-websocket#v1
```

### Usage

First you need to register the core plugin with Tauri:

`src-tauri/src/main.rs`

```rust
fn main() {
    tauri::Builder::default()
        .plugin(tauri_plugin_websocket::init())
        .run(tauri::generate_context!())
        .expect("error while running tauri application");
}
```

Afterwards all the plugin's APIs are available through the JavaScript guest bindings:

```js
import WebSocket from "tauri-plugin-websocket-api";

const ws = await WebSocket.connect("wss://example.com");

await ws.send("Hello World");

await ws.disconnect();
```
