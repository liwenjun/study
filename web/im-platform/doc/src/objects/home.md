# 对象

本目录列出了全部 `API` 所使用的通用对象。

## Snowflakes

Most if not all objects are identified by a [snowflake ID](https://en.wikipedia.org/wiki/Snowflake_ID) with a custom epoch
of `2023-01-01T00:00:00Z`. Therefore, to obtain the creation timestamp of an object, you can use the following formula:

```python
EPOCH = 1672531200000 # 2023-01-01T00:00:00Z in milis
created_at = (id >> 22) + EPOCH
```

> Note: Snowflakes are delivered as strings by the API to ensure language compatibility, but they are guaranteed to be numeric.
