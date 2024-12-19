# /guilds

## POST

### Summary

Creates a guild.

### Payload

```json
{
    "name": "Among Us",
}
```

### Response

The created [Guild](../objects/guild.md) object.

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
```

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
