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
    app.ports.callConnectWsserver.subscribe(function ({ url, data }) {
      console.info("连接Ws =>", url);
      console.info("连接Ws =>", data);
      ws = new WebSocket(url);
      ws.onopen = function (ev) {
        ws.send(typeof data === "string" ? data : JSON.stringify(data));
        app.ports.subWsserverState.send(true);
      };
      ws.onclose = function (ev) {
        app.ports.subWsserverState.send(false);
        app.ports.subRecvWsmessage.send({
          type: ev.type,
          code: ev.code,
          reason: JSON.parse(ev.reason),
        });
      };
      ws.onerror = function (ev) {
        console.error("1错误", ev);
        // app.ports.subWsserverState.send(false);
        app.ports.subRecvWsmessage.send({
          type: ev.type,
          code: ev.code,
          reason: JSON.parse(ev.reason),
          // typeof msg === "string" ? msg : JSON.stringify(ev)
        });
      };
      ws.onmessage = function (ev) {
        console.log("收信", ev);
        app.ports.subRecvWsmessage.send({
          type: ev.type,
          data: JSON.parse(ev.data),
        });
      };
    });

    // 断开
    app.ports.callDisconnectWsserver.subscribe(function () {
      ws.close(1000, "我把它关了");
    });

    // 发送ws消息
    app.ports.callSendWsmessage.subscribe(function (msg) {
      console.log("发送消息", msg);
      ws.send(typeof msg === "string" ? msg : JSON.stringify(msg));
    });

    // 保存数据到本地
    app.ports.sendToLocalStorage.subscribe(({ key, value }) => {
      window.localStorage[key] =
        typeof value === "string" ? value : JSON.stringify(value);
    });
  }
};
