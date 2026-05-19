---
title: "Utilities"
weight: 21
summary: "UUID generation, timestamps, and URL encoding helpers"
---

### $bolt.uuid()
Generate UUID v4.

```ring
id = $bolt.uuid()  # "550e8400-e29b-41d4-a716-446655440000"
```

### $bolt.unixtime()
Get current Unix timestamp (seconds).

```ring
ts = $bolt.unixtime()  # 1706889600
```

### $bolt.unixtimeMs()
Get current Unix timestamp (milliseconds).

```ring
ts = $bolt.unixtimeMs()  # 1706889600123
```

### $bolt.urlEncode(cStr)
URL-encode a string.

```ring
encoded = $bolt.urlEncode("hello world")  # "hello%20world"
```

### $bolt.urlDecode(cStr)
URL-decode a string.

```ring
decoded = $bolt.urlDecode("hello%20world")  # "hello world"
```

### $bolt.base64Encode(cStr)
Encode a string as base64.

```ring
encoded = $bolt.base64Encode("hello world")  # "aGVsbG8gd29ybGQ="
```

### $bolt.base64Decode(cStr)
Decode a base64-encoded string.

```ring
decoded = $bolt.base64Decode("aGVsbG8gd29ybGQ=")  # "hello world"
```

### $bolt.base64UrlEncode(cStr)
Encode a string as URL-safe base64 (replaces `+` with `-`, `/` with `_`).

```ring
encoded = $bolt.base64UrlEncode("hello world")  # "aGVsbG8gd29ybGQ"
```

### $bolt.base64UrlDecode(cStr)
Decode a URL-safe base64-encoded string.

```ring
decoded = $bolt.base64UrlDecode("aGVsbG8gd29ybGQ")  # "hello world"
```
