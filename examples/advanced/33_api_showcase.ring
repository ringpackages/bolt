# API Showcase - Combines multiple Bolt features
# Run: ring 33_api_showcase.ring

load "bolt.ring"

# Create .env file if missing
if !fexists(currentdir() + "/.env")
    # Only write non-secret config to .env
    # Set JWT_SECRET, ENCRYPTION_KEY, COOKIE_SECRET as environment variables before running
    write(currentdir() + "/.env", "PORT=3000" + nl + "APP_ENV=development" + nl)
ok

env = new Env()
hash = new Hash
v = new Validate
s = new Sanitize
crypto = new Crypto
dt = new DateTime

cJwtSecret = env.getOr("JWT_SECRET", "change-me-in-production")
if env.getVar("JWT_SECRET") = ""
    ? "WARNING: JWT_SECRET not set, using insecure default"
ok
cEncryptionKey = env.getOr("ENCRYPTION_KEY", "bolt-demo-change-me-in-production!!")
if env.getVar("ENCRYPTION_KEY") = ""
    ? "WARNING: ENCRYPTION_KEY not set, using insecure default"
ok
aUsers = []
nNextId = 1

new Bolt() {
    port = 0 + env.getOr("PORT", "3000")

    setBodyLimit(10 * 1024 * 1024)
    setTimeout(30000)
    setSessionCapacity(10000)
    setSessionTTL(3600)
    setCacheCapacity(5000)
    setCacheTTL(300)

    enableCors()
    # Use specific origins instead of wildcard
    corsOrigin("http://localhost:3000")
    corsOrigin("http://localhost:8080")
    enableCompression()
    enableLogging()
    setCookieSecret(env.getOr("COOKIE_SECRET", "cookie-secret-32-chars-min!"))
    if env.getVar("COOKIE_SECRET") = ""
        ? "WARNING: COOKIE_SECRET not set, using insecure default"
    ok

    setDocsInfo("Bolt Demo API", "1.0.0", "A full-featured demo combining all Bolt capabilities")
    enableDocs()

    @get("/", func {
        $bolt.renderFile("./templates/layout.html", [
            :title = "Bolt Demo API",
            :subtitle = "A full-featured demo combining all Bolt capabilities",
            :sections = [
                [:title = "Test with curl", :subsections = [
                    [:title = "Get current server time", :code = "curl http://localhost:3000/api/v1/time"],
                    [:title = "Generate a UUID v4", :code = "curl http://localhost:3000/api/v1/uuid"],
                    [:title = "Hash a password with Argon2", :code = `curl -X POST http://localhost:3000/api/v1/hash -H "Content-Type: application/json" -d '{"password":"mypassword"}'`],
                    [:title = "Encrypt text with AES-256-GCM", :code = `curl -X POST http://localhost:3000/api/v1/encrypt -H "Content-Type: application/json" -d '{"text":"secret data"}'`],
                    [:title = "Decrypt AES-256-GCM ciphertext", :code = `curl -X POST http://localhost:3000/api/v1/decrypt -H "Content-Type: application/json" -d '{"ciphertext":"CIPHERTEXT_HERE"}'`],
                    [:title = "Register a new user", :code = `curl -X POST http://localhost:3000/api/v1/register -H "Content-Type: application/json" -d '{"name":"Alice","email":"alice@example.com","password":"secret123"}'`],
                    [:title = "Login", :code = `curl -X POST http://localhost:3000/api/v1/login -H "Content-Type: application/json" -d '{"email":"alice@example.com","password":"secret123"}'`],
                    [:title = "List all users", :code = "curl http://localhost:3000/api/v1/users"],
                    [:title = "Get user by ID", :code = "curl http://localhost:3000/api/v1/users/1"],
                    [:title = "Get authenticated profile", :code = 'curl http://localhost:3000/api/v1/profile -H "Authorization: Bearer YOUR_TOKEN"'],
                    [:title = "Health check", :code = "curl http://localhost:3000/api/v1/health"],
                    [:title = "Subscribe to SSE events", :code = "curl -N http://localhost:3000/events"],
                    [:title = "Broadcast a notification", :code = `curl -X POST http://localhost:3000/notify -H "Content-Type: application/json" -d '{"message":"Hello everyone!"}'`]
                ]],
                [:title = "Interactive Docs", :text = "Visit /docs for auto-generated OpenAPI documentation"]
            ]
        ])
    })

    $bolt.rateLimit(100, 60)

    @before(func {
        $bolt.setHeader("X-Request-Id", $bolt.requestId())
        $bolt.setHeader("X-Response-Time", "" + $bolt.unixtimeMs())

        if !$bolt.checkRateLimit()
            $bolt.setHeader("Retry-After", "60")
            $bolt.sendWithStatus(429, "Too many requests")
        ok
    })

    @after(func {
        $bolt.logWithLevel("[" + $bolt.method() + "] " + $bolt.path() + " " + $bolt.clientIp(), "info")
    })

    prefix("/api/v1")

        @get("/time", func {
            nTs = dt.timestamp()
            $bolt.json([
                :unix = nTs,
                :iso = dt.formatDate(nTs, "%Y-%m-%dT%H:%M:%S"),
                :utc = dt.nowUtc(),
                :next_week = dt.formatDate(dt.addDays(nTs, 7), "%Y-%m-%d")
            ])
        })
        describe("Get current server time")
        tag("Utils")

        @get("/uuid", func {
            $bolt.json([:uuid = $bolt.uuid()])
        })
        describe("Generate a UUID v4")
        tag("Utils")

        @post("/hash", func {
            data = $bolt.jsonBody()
            $bolt.json([:argon2 = hash.argon2(data[:password])])
        })
        describe("Hash a password with Argon2")
        tag("Utils")

        @post("/encrypt", func {
            data = $bolt.jsonBody()
            $bolt.json([:encrypted = crypto.aesEncrypt(data[:text], cEncryptionKey)])
        })
        describe("Encrypt text with AES-256-GCM")
        tag("Utils")

        @post("/decrypt", func {
            data = $bolt.jsonBody()
            cB64 = crypto.aesDecrypt(data[:ciphertext], cEncryptionKey)
            $bolt.json([:decrypted = $bolt.base64Decode(cB64)])
        })
        describe("Decrypt AES-256-GCM ciphertext")
        tag("Utils")

        @post("/register", func {
            data = $bolt.jsonBody()

            if !v.email(data[:email])
                $bolt.badRequest("Invalid email")
                return
            ok
            if !v.length(data[:name], 2, 100)
                $bolt.badRequest("Name must be 2-100 characters")
                return
            ok

            cSafeName = s.escapeHtml(data[:name])
            cHashedPass = hash.argon2(data[:password])

            aUser = [
                :id = nNextId,
                :name = cSafeName,
                :email = data[:email],
                :password_hash = cHashedPass
            ]
            add(aUsers, aUser)
            nNextId++

            cToken = $bolt.jwtEncodeExp([:user_id = aUser[:id], :email = aUser[:email]], cJwtSecret, 3600)
            $bolt.jsonWithStatus(201, [:id = aUser[:id], :name = cSafeName, :token = cToken])
        })
        describe("Register a new user")
        tag("Users")

        @post("/login", func {
            data = $bolt.jsonBody()
            bFound = false

            for aUser in aUsers
                if aUser[:email] = data[:email]
                    bFound = true
                    if hash.verifyArgon2(data[:password], aUser[:password_hash])
                        cToken = $bolt.jwtEncodeExp([:user_id = aUser[:id], :email = aUser[:email]], cJwtSecret, 3600)
                        $bolt.setSignedCookie("user_id", "" + aUser[:id])
                        $bolt.setSession("email", aUser[:email])
                        $bolt.setFlash("success", "Welcome back!")
                        $bolt.json([:success = true, :token = cToken])
                    else
                        $bolt.jsonWithStatus(401, [:error = "Invalid password"])
                    ok
                    exit
                ok
            next

            if !bFound
                $bolt.jsonWithStatus(401, [:error = "User not found"])
            ok
        })
        describe("Login with email and password")
        tag("Users")
        routeRateLimit(5, 60)

        @get("/users", func {
            cCached = $bolt.cacheGet("users_list")
            if cCached != ""
                $bolt.json($bolt.jsonDecode(cCached))
                return
            ok

            aSafeUsers = []
            for aUser in aUsers
                add(aSafeUsers, [:id = aUser[:id], :name = aUser[:name], :email = aUser[:email]])
            next

            $bolt.cacheSetTTL("users_list", $bolt.jsonEncode(aSafeUsers), 60)
            $bolt.json(aSafeUsers)
        })
        describe("List all users")
        tag("Users")

        @get("/users/:id", func {
            nId = 0 + $bolt.param("id")
            for aUser in aUsers
                if aUser[:id] = nId
                    $bolt.json([:id = aUser[:id], :name = aUser[:name], :email = aUser[:email]])
                    return
                ok
            next
            $bolt.notFound()
        })
        where("id", "^[0-9]+$")
        describe("Get user by ID")
        tag("Users")

        @get("/profile", func {
            cAuth = $bolt.header("Authorization")
            if cAuth = ""
                cUserId = $bolt.getSignedCookie("user_id")
                if cUserId != ""
                    cEmail = $bolt.getSession("email")
                    cFlash = ""
                    if $bolt.hasFlash("success")
                        cFlash = $bolt.getFlash("success")
                    ok
                    $bolt.json([:user_id = cUserId, :email = cEmail, :flash = cFlash])
                    return
                ok
                $bolt.unauthorized()
                return
            ok

            cToken = substr(cAuth, 8)
            if $bolt.jwtVerify(cToken, cJwtSecret)
                aClaims = $bolt.jwtDecode(cToken, cJwtSecret)
                $bolt.json([:authenticated = true, :claims = aClaims])
            else
                $bolt.jsonWithStatus(401, [:error = "Invalid token"])
            ok
        })
        describe("Get authenticated user profile")
        tag("Users")

        @get("/health", func {
            $bolt.json($bolt.healthCheck())
        })
        describe("Server health check")
        tag("System")

    endPrefix()

    @error(func {
        $bolt.jsonWithStatus(500, [
            :error = "Internal server error",
            :path = $bolt.path(),
            :method = $bolt.method(),
            :request_id = $bolt.requestId()
        ])
    })

    @sse("/events")

    @post("/notify", func {
        data = $bolt.jsonBody()
        $bolt.sseBroadcast("/events", data[:message])
        $bolt.json([:sent = true])
    })
}
