# users

## 创建用户

### Summary

Creates a new user.

### Payload

```json
{
    "jsonrpc": "2.0",
    "method": "users.create",
    "auth": null,
    "params": {"username": "user", "password": "********"},
    "id": 1
}
```

### Response

The created [User](../objects/user.md) object.

```json
{
  "jsonrpc": "2.0",
  "id": 1,
  "result": {
    "id": "71395574100676609",
    "username": "user",
    "display_name": "user",
    "presence": null
  }
}
```

### Errors

```json
{
    "jsonrpc": "2.0",
    "id": 1,
    "error": {
        "code": -32603,
        "message": "内部错误",
        "data": "User with username user already exists"
    }
}
```



| Code | Description |
| ---- | ----------- |
| 400  | The username is invalid. |
| 400  | The username is already taken. |

# /users/auth

## 登录

### Summary

Authenticates a user, providing an authorization token for use in the REST API and gateway.

### Payload

```json
{
    "jsonrpc": "2.0",
    "method": "users.auth",
    "auth": null,
    "params": {"username": "user", "password": “********”},
    "id": 1
}
```

### Response

```json
{
    "jsonrpc":"2.0",
    "id":1,
    "result":{"user_id":"71395574100676609", "token":"********"}
}
```

### Errors

```json
{
    "jsonrpc": "2.0",
    "id": 1,
    "error": {
        "code": -32603,
        "message": "内部错误",
        "data": "invalid password"
    }
}
```





| Code | Description |
| ---- | ----------- |
| 401  | The username or password is incorrect. |

# /users/@self

## GET

### Summary

Gets the authenticated user's data.

### Response

A [User](../objects/user.md) object.

# /users/@self/guilds

## GET

### Summary

Gets the authenticated user's guilds.

### Response

An array of [Guild](../objects/guild.md) objects.

# /users/@self/presence

## PATCH

### Summary

Updates the authenticated user's presence.

> Note: This endpoint will most likely be removed in favour of updating the user's presence via the gateway.

### Payload

```json
{
    "ONLINE"
}
```

### Response

The updated presence.

```json
{
    "ONLINE"
}
```

# /users/\{username\}

## GET

### Summary

Query the existence of a user with the given username. 
This endpoint is mainly designed for use in registration forms to check if a username is already taken.

### Payload

```json
{
    "jsonrpc": "2.0",
    "method": "users.check",
    "auth": null,
    "params": ["{{checkuser}}"],
    "id": 1
}
```

### Response

An empty response indicating the user exists.

```json
{
    "jsonrpc": "2.0",
    "id": 1,
    "result": true
}
```

### Errors

```json
{
    "jsonrpc": "2.0",
    "id": 1,
    "result": false
}
```



| Code | Description |
| ---- | ----------- |
| 404  | The user with the given username was not found. |
