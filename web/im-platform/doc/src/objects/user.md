# User

A user represents a guild-agnostic platform-user. To get a user's guild-specific information, see [Member](member.md).

## 字段

| Field | Type | Description |
| --- | --- | --- |
| id | `Snowflake` | The user's snowflake ID |
| username | `String` | The user's username, must conform to regex `^([a-zA-Z0-9]\|[a-zA-Z0-9][a-zA-Z0-9]*(?:[._][a-zA-Z0-9]+)*[a-zA-Z0-9])$` |
| display_name | `String` | The user's display name |
| presence | `String?` | The user's presence, this field is only present in `GUILD_CREATE` and `READY` gateway events. |

### presence 的可能值

- `"ONLINE"`
- `"IDLE"`
- `"BUSY"`
- `"OFFLINE"`

## 范例

```json
{
    "id": "123456789123456789",
    "username": "among_us",
    "display_name": "Among Us",
    "presence": "ONLINE"
}
```
