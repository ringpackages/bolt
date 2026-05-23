# Validate & Sanitize - Input validation and HTML sanitization
# Run: ring 18_validate_sanitize.ring

load "bolt.ring"

v = new Validate
s = new Sanitize

new Bolt() {
    port = 3000

    # Validate email
    @get("/validate/email/:email", func {
        cEmail = $bolt.param("email")
        if v.email(cEmail)
            $bolt.json([:valid = true, :email = cEmail])
        else
            $bolt.jsonWithStatus(400, [:valid = false, :error = "Invalid email format"])
        ok
    })

    # Validate URL
    @get("/validate/url/:url", func {
        cUrl = $bolt.param("url")
        if v.url(cUrl)
            $bolt.json([:valid = true, :url = cUrl])
        else
            $bolt.jsonWithStatus(400, [:valid = false, :error = "Invalid URL format"])
        ok
    })

    # Validate IP address
    @get("/validate/ip/:ip", func {
        cIp = $bolt.param("ip")
        $bolt.json([
            :ip = cIp,
            :isIp = v.ip(cIp),
            :isIpv4 = v.ipv4(cIp),
            :isIpv6 = v.ipv6(cIp)
        ])
    })

    # Validate UUID
    @get("/validate/uuid/:uuid", func {
        cUuid = $bolt.param("uuid")
        if v.uuid(cUuid)
            $bolt.json([:valid = true, :uuid = cUuid])
        else
            $bolt.jsonWithStatus(400, [:valid = false, :error = "Invalid UUID format"])
        ok
    })

    # Validate string length and number range
    @post("/validate/user", func {
        data = $bolt.jsonBody()

        aErrors = []

        if !v.length(data[:name], 2, 50)
            aErrors + "Name must be 2-50 characters"
        ok

        if !v.email(data[:email])
            aErrors + "Invalid email format"
        ok

        if !v.range(data[:age], 0, 150)
            aErrors + "Age must be between 0 and 150"
        ok

        if !v.alphanumeric(data[:username])
            aErrors + "Username must be alphanumeric"
        ok

        if len(aErrors) > 0
            $bolt.jsonWithStatus(400, [:valid = false, :errors = aErrors])
        else
            $bolt.json([:valid = true, :user = data])
        ok
    })

    # Validate JSON string
    @post("/validate/json", func {
        cBody = $bolt.body()
        if v.jsonString(cBody)
            $bolt.json([:valid = true, :message = "Valid JSON"])
        else
            $bolt.jsonWithStatus(400, [:valid = false, :error = "Invalid JSON"])
        ok
    })

    # Validate character classes
    @get("/validate/alpha/:str", func {
        cStr = $bolt.param("str")
        $bolt.json([
            :input = cStr,
            :alpha = v.alpha(cStr),
            :alphanumeric = v.alphanumeric(cStr),
            :numeric = v.numeric(cStr)
        ])
    })

    # Sanitize HTML - strip dangerous tags, keep safe ones
    @post("/sanitize/html", func {
        data = $bolt.jsonBody()
        cSafe = s.html(data[:input])
        $bolt.json([
            :original = data[:input],
            :sanitized = cSafe,
            :method = "html (strip dangerous, keep safe)"
        ])
    })

    # Sanitize HTML - strict mode (strip ALL tags)
    @post("/sanitize/strict", func {
        data = $bolt.jsonBody()
        cSafe = s.strict(data[:input])
        $bolt.json([
            :original = data[:input],
            :sanitized = cSafe,
            :method = "strict (strip all tags)"
        ])
    })

    # Escape HTML entities
    @post("/sanitize/escape", func {
        data = $bolt.jsonBody()
        cEscaped = s.escapeHtml(data[:input])
        $bolt.json([
            :original = data[:input],
            :escaped = cEscaped,
            :method = "escapeHtml (convert to entities)"
        ])
    })

    # Comment submission with validation + sanitization
    @post("/comment", func {
        data = $bolt.jsonBody()

        if !v.length(data[:text], 1, 500)
            $bolt.badRequest("Comment must be 1-500 characters")
            return
        ok

        cSafeComment = s.html(data[:text])
        $bolt.json([
            :success = true,
            :comment = cSafeComment,
            :note = "Dangerous HTML stripped, safe HTML preserved"
        ])
    })

    @get("/", func {
        $bolt.html(`
<h1>Validate & Sanitize</h1>
<h3>Validation:</h3>
<pre>
# Email
curl http://localhost:3000/validate/email/user@example.com

# URL
curl http://localhost:3000/validate/url/https://example.com

# IP
curl http://localhost:3000/validate/ip/192.168.1.1

# UUID
curl http://localhost:3000/validate/uuid/550e8400-e29b-41d4-a716-446655440000

# User validation (length, email, range, alphanumeric)
curl -X POST http://localhost:3000/validate/user \
  -H 'Content-Type: application/json' \
  -d '{"name":"Alice","email":"alice@example.com","age":25,"username":"alice123"}'

# Validate JSON string
curl -X POST http://localhost:3000/validate/json \
  -H 'Content-Type: application/json' \
  -d '{"key":"value"}'

# Character classes
curl http://localhost:3000/validate/alpha/hello123
</pre>

<h3>Sanitization:</h3>
<pre>
# Strip dangerous HTML
curl -X POST http://localhost:3000/sanitize/html \
  -H 'Content-Type: application/json' \
  -d '{"input":"&lt;script&gt;alert(1)&lt;/script&gt;&lt;p&gt;Safe&lt;/p&gt;"}'

# Strip ALL tags
curl -X POST http://localhost:3000/sanitize/strict \
  -H 'Content-Type: application/json' \
  -d '{"input":"&lt;b&gt;Bold&lt;/b&gt; &lt;script&gt;evil()&lt;/script&gt;"}'

# Escape HTML entities
curl -X POST http://localhost:3000/sanitize/escape \
  -H 'Content-Type: application/json' \
  -d '{"input":"&lt;div class=test&gt;Hello &amp; goodbye&lt;/div&gt;"}'

# Comment with validation + sanitization
curl -X POST http://localhost:3000/comment \
  -H 'Content-Type: application/json' \
  -d '{"text":"&lt;b&gt;Nice post!&lt;/b&gt;"}'
</pre>
        `)
    })
}
