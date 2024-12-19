# guilds

## 创建

### Summary

Creates a guild.

### Payload

```json
{
    "jsonrpc": "2.0",
    "method": "guilds.create",
    "auth": "{{token}}",
    "params": { "name": "{{guildname}}" },
    "id": 1
}
```

### Response

The created [Guild](../objects/guild.md) object.

```json
{
    "jsonrpc": "2.0",
    "id": 1,
    "result": {
        "id": "71399844606791681",
        "name": "营销运维",
        "owner_id": "71395574100676609"
    }
}
```

### Error

```json
{
    "jsonrpc": "2.0",
    "id": 1,
    "error": {
        "code": -32600,
        "message": "无效请求",
        "data": "未授权访问"
    }
}
```


# /guilds/\{guild_id\}

## GET

### Summary

Gets a guild's data.

### Response

A [Guild](../objects/guild.md) object.

### Errors

| Code | Description |
| ---- | ----------- |
| 404  | The guild was not found. |

# /guilds/\{guild_id\}/channels

## POST

### Summary

Creates a channel in a guild.

### Example Payload

```json
{
    "type": "GUILD_TEXT", // Currently only this channel-type is supported
    "name": "channel-name",
}
````

### Response

The created [Channel](../objects/channel.md) object.

### Errors

| Code | Description |
| ---- | ----------- |
| 404  | The guild was not found. |

# /guilds/\{guild_id\}/members

## POST

### Summary

Adds the currently authenticated user as a member to a guild. If the member is already in the guild, this will simply return the member's data.

### Response

The created [Member](../objects/member.md) object.

### Errors

| Code | Description |
| ---- | ----------- |
| 404  | The guild was not found. |

# /guilds/\{guild_id\}/members/\{user_id\}

## GET

### Summary

Gets a member's data. Use `@self` as the `user_id` to get the authenticated user's data.

### Response

A [Member](../objects/member.md) object.

### Errors

| Code | Description |
| ---- | ----------- |
| 404  | The member or guild was not found. |

## DELETE

### Summary

Removes a member from a guild.

> Note: This endpoint currently only supports the use of `@self` as the `user_id`.

### Response

An empty response.

### Errors

| Code | Description |
| ---- | ----------- |
| 404  | The member or guild was not found. |

## 发送消息

### Summary

Sends a message to a guild.

### Payload

```json
{
    "content": "sus",
    "nonce": "this will be echoed back by the gateway!"
}
```

### Response

The created [Message](../objects/message.md) object.

### Errors

| Code | Description                                             |
| ---- | ------------------------------------------------------- |
| 403  | The user is not in the guild the channel is located in. |
| 404  | The channel was not found.                              |
