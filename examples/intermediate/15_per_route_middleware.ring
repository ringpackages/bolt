# Per-Route Middleware - before, after, routeRateLimit, @use
# Run: ring 15_per_route_middleware.ring

load "bolt.ring"

new Bolt() {
    port = 3000

    enableLogging()

    @use("global_use_middleware")

    @before(func {
        $bolt.setHeader("X-Request-Id", $bolt.requestId())
        $bolt.setHeader("X-Response-Time", "" + $bolt.unixtimeMs())
    })

    @after(func {
        $bolt.log("[AFTER] " + $bolt.method() + " " + $bolt.path() + " completed")
    })

    @get("/public", func {
        $bolt.json([:message = "No auth needed here"])
    })

    # Per-route before middleware: adds auth header check log
    @get("/protected", func {
        cAuth = $bolt.header("Authorization")
        if cAuth = ""
            $bolt.unauthorized()
            return
        ok
        $bolt.json([:message = "Auth passed", :token = cAuth])
    })
    before("auth_logger")

    # Per-route after middleware: logs response for this route
    @get("/tracked", func {
        $bolt.json([:message = "This route is tracked"])
    })
    after("log_middleware")

    # Per-route rate limiting (5 requests per 60 seconds)
    @post("/login", func {
        $bolt.json([:message = "Login attempt recorded"])
    })
    routeRateLimit(5, 60)

    @get("/", func {
        $bolt.html(`
<h1>Per-Route Middleware Example</h1>
<h3>Try these:</h3>
<pre>
# Public route (no auth)
curl http://localhost:3000/public

# Protected route (needs auth)
curl http://localhost:3000/protected
curl http://localhost:3000/protected -H "Authorization: Bearer mytoken"

# Tracked route (after middleware logs to console)
curl http://localhost:3000/tracked

# Rate limited login (5 req/min)
curl -X POST http://localhost:3000/login
</pre>
        `)
    })
}

func global_use_middleware {
    $bolt.setHeader("X-App", "Bolt")
}

func auth_logger {
    $bolt.log("[AUTH-CHECK] " + $bolt.method() + " " + $bolt.path() + " from " + $bolt.clientIp())
}

func log_middleware {
    $bolt.log("[ROUTE-AFTER] " + $bolt.method() + " " + $bolt.path())
}
