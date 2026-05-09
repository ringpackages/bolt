---
title: "Request"
weight: 5
summary: "HTTP method, path, URL params, query strings, headers, body, and client info"
---

### $bolt.method()
Get HTTP method.

```ring
m = $bolt.method()  # "GET", "POST", etc.
```

### $bolt.path()
Get request path (route pattern).

```ring
p = $bolt.path()  # "/users/:id" (route pattern, not actual URI)
```

### $bolt.uri()
Get raw request URI (actual path including query string).

```ring
u = $bolt.uri()  # "/users/123?tab=profile"
```

### $bolt.param(cName)
Get URL parameter.

```ring
# Route: /users/:id
id = $bolt.param("id")
```

### $bolt.query(cName)
Get query string parameter (first value if multi-valued).

```ring
# URL: /search?q=hello&page=1
q = $bolt.query("q")        # "hello"
page = $bolt.query("page")  # "1"
```

### $bolt.queryAll(cName)
Get all values for a query parameter as a list. Useful for `?tag=rust&tag=web` patterns.

```ring
# URL: /search?tag=rust&tag=web
tags = $bolt.queryAll("tag")  # ["rust", "web"]
```

### $bolt.header(cName)
Get request header.

```ring
auth = $bolt.header("Authorization")
contentType = $bolt.header("Content-Type")
```

### $bolt.body()
Get raw request body as string (lossy UTF-8 — binary bytes replaced with U+FFFD).

```ring
raw = $bolt.body()
```

### $bolt.bodyBase64()
Get raw request body as base64-encoded string (binary-safe).

```ring
encoded = $bolt.bodyBase64()
```

### $bolt.jsonBody()
Parse request body as JSON.

```ring
data = $bolt.jsonBody()
name = data[:name]
```

### $bolt.formField(cName)
Get form field value from multipart form data (first value if multi-valued).

```ring
username = $bolt.formField("username")
password = $bolt.formField("password")
```

### $bolt.formFieldAll(cName)
Get all values for a form field as a list. Useful for checkbox arrays and multi-select inputs.

```ring
# <input type="checkbox" name="hobby" value="reading">
# <input type="checkbox" name="hobby" value="coding">
hobbies = $bolt.formFieldAll("hobby")  # ["reading", "coding"]
```

### $bolt.requestId()
Get unique request ID.

```ring
id = $bolt.requestId()  # "550e8400-e29b-41d4-a716-446655440000"
```

### $bolt.clientIp()
Get client IP address.

```ring
ip = $bolt.clientIp()  # "192.168.1.100"
```
