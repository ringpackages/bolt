load "bolt.ring"


new Bolt() {
    cPort = sysget("BOLT_TEST_PORT")
    if cPort = "" { cPort = "3000" }
    port = number(cPort)

    rateLimit(100, 60)

    @get("/health", func {
        $bolt.json([:status = "ok"])
    })

    @get("/limited", func {
        $bolt.json([:ok = 1])
    })
    routeRateLimit(3, 60)

    @post("/limited-post", func {
        $bolt.json([:ok = 1])
    })
    routeRateLimit(2, 60)

    @get("/global-limited", func {
        $bolt.json([:ok = 1])
    })
    routeRateLimit(5, 60)

    @get("/limited", func {
        $bolt.json([:ok = true])
    })
    routeRateLimit(3, 60)

    @post("/limited-post", func {
        $bolt.json([:ok = true])
    })
    routeRateLimit(2, 60)

    @get("/global-limited", func {
        $bolt.json([:ok = true])
    })

    @get("/limited-short-window", func {
        $bolt.json([:ok = 1])
    })
    routeRateLimit(2, 2)

    @get("/check-rate-limit", func {
        allowed = $bolt.checkRateLimit()
        $bolt.json([:allowed = allowed])
    })

    @error(func {
        $bolt.jsonWithStatus(500, [:error = true, :custom_error = true, :path = $bolt.path()])
    })

    @get("/cause-error", func {
        raise("intentional error")
    })

    @get("/health-check", func {
        $bolt.json($bolt.healthCheck())
    })

    ipWhitelist("127.0.0.1")
    ipBlacklist("10.0.0.1")
    proxyWhitelist("127.0.0.1")

    @get("/ip-allowed", func {
        $bolt.json([:allowed = true])
    })

    @get("/request/info", func {
        $bolt.json([
            :method = $bolt.method(),
            :path = $bolt.path(),
            :uri = $bolt.uri(),
            :ip = $bolt.clientIp(),
            :requestid = $bolt.requestId(),
            :useragent = $bolt.header("User-Agent")
        ])
    })

    @post("/json-body", func {
        $bolt.json([:parsed = true, :data = $bolt.jsonBody()])
    })

    @get("/ip-blocked", func {
        ip = $bolt.clientIp()
        $bolt.json([:ip = ip])
    })

    @get("/proxy-used", func {
        ip = $bolt.clientIp()
        $bolt.json([:ip = ip])
    })
}
