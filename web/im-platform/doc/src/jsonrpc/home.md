# Jsonrpc API

这类 `API` 主要用于查询和修改 [objects](../objects/home.md) 。

## 认证流程

The REST API uses JWT tokens for authentication. These tokens are obtained by sending a `POST` to `/users/auth` with the following JSON body:

```json
{
    "jsonrpc": "2.0",
    "method": "users.auth",
    "auth": null,
    "params": {"username": "user", "password": “********”},
    "id": 1
}
```

> To create a user, see [this section](./users.md#/users).

Upon successfully authenticating, the server will respond with a payload like this one:

```json
{
    "jsonrpc":"2.0",
    "id":1,
    "result":{"user_id":"71395574100676609", "token":"********"}
}
```

The `token` field is the JWT token that should be used for authentication. It should be sent in the `Authorization` header of all requests to the REST API. In the case the client sent an invalid or expired token, the server will respond with a `401 Unauthorized` status code, and the client is expected to re-authenticate.
