# Gateway

`gateway` 是一个 `websocket` 连接，用于实时通讯。主要用于发送消息和通知等。

## 认证流程

After connecting to the gateway (located at `/gateway`), the client is expected to send an `IDENTIFY` payload, the format of which is as follows:

```json
{
    "event": "IDENTIFY",
    "data": {
        "token": "***********************"
    }
}
```

The socket will then respond with a [`READY`](./events.md#READY) event, which contains the client's user data, as well as the guilds the client is in.

Once `READY` is received, the client will start receiveing [`GUILD_CREATE`](./events.md#GUILD_CREATE) events for all guilds which they are a member of, which contain the guild's data, as well as all the channels and members in it.
