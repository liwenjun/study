import { invoke } from "@tauri-apps/api";
import WebSocket from "tauri-plugin-websocket-api";

/*
// 设置开发调试环境
if (process.env.NODE_ENV === "development") {
  const ElmDebugTransform = await import("elm-debug-transformer");

  ElmDebugTransform.register({
    simple_mode: true,
  });
}
*/

// This is called BEFORE your Elm app starts up
//
// The value returned here will be passed as flags
// into your `Shared.init` function.
export const flags = ({ env }) => {
  return {
    user: JSON.parse(window.localStorage.user || null),
    guild: window.localStorage.guild || null,
    origin: "http://127.0.0.1:8080",
    //origin: window.location.origin,
  };
};

// This is called AFTER your Elm app starts up
//
// Here you can work with `app.ports` to send messages
// to your Elm application, or subscribe to incoming
// messages from Elm
export const onReady = ({ app, env }) => {
  if (app.ports) {
    // 定义全局变量
    let ws;

    // 连接ws服务器
    app.ports.callConnectWsserver.subscribe(async ({ url, data }) => {
      console.log("连接 => ", url, data);
      ws = await WebSocket.connect(url).then(r => { return r }).catch(receiver);
      ws.addListener(receiver);
      await sender(data);
    });

    function receiver(msg) {
      console.log("收信", msg);
      // typeof msg === "string" ? msg : JSON.stringify(msg)
      app.ports.subRecvWsmessage.send({
        type: msg.type,
        data: JSON.parse(msg.data),
      });

    }

    async function sender(msg) {
      console.log("发信", msg);
      await ws.send(typeof msg === "string" ? msg : JSON.stringify(msg));
    }

    // 断开
    app.ports.callDisconnectWsserver.subscribe(async function () {
      await ws.disconnect();
    });

    // 发送ws消息
    app.ports.callSendWsmessage.subscribe(sender);

    // 保存数据到本地
    app.ports.sendToLocalStorage.subscribe(({ key, value }) => {
      window.localStorage[key] =
        typeof value === "string" ? value : JSON.stringify(value);
    });
  }
};
