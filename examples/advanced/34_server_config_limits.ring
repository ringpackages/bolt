# Advanced Server Configuration & Limits
# Run: ring 34_server_config_limits.ring
# Demonstrates: setMultipartFieldCountLimit, setMultipartFieldSizeLimit,
#               setWsMaxConnections, setWsMaxPerIp, setWsMessageRateLimit

load "bolt.ring"

new Bolt() {
    port = 3000

    setTimeout(30000)
    setBodyLimit(5 * 1024 * 1024)
    forceSecureCookies()

    setMultipartFieldCountLimit(50)
    setMultipartFieldSizeLimit(5 * 1024 * 1024)

    setSessionCapacity(5000)
    setSessionTTL(7200)
    setCacheCapacity(1000)
    setCacheTTL(600)

    @get("/health", func {
        $bolt.json([:status = "ok", :service = "config-limits-demo"])
    })

    @get("/config", func {
        $bolt.json([
            :timeout = "30s",
            :bodyLimit = "5MB",
            :multipartFields = 50,
            :multipartSize = "5MB",
            :sessionCapacity = 5000,
            :sessionTTL = "2h",
            :cacheCapacity = 1000,
            :cacheTTL = "10min"
        ])
    })

    @get("/", func {
        $bolt.renderFile("./templates/layout.html", [
            :title = "Bolt - Advanced Config & Limits",
            :subtitle = "Server configuration, multipart limits, WebSocket limits",
            :sections = [
                [:title = "Endpoints", :items = [
                    "/config - View current configuration",
                    "/health - Health check"
                ]],
                [:title = "Configured Limits", :code = `setTimeout(30000)           -> 30 second request timeout
setBodyLimit(5MB)           -> Max 5MB request body
forceSecureCookies()        -> Force Secure flag on cookies
setMultipartFieldCountLimit(50)   -> Max 50 multipart fields
setMultipartFieldSizeLimit(5MB)   -> Max 5MB per field
setSessionCapacity(5000)    -> Max 5000 sessions
setSessionTTL(7200)         -> 2 hour session TTL
setCacheCapacity(1000)      -> Max 1000 cache entries
setCacheTTL(600)            -> 10 minute cache TTL`]
            ]
        ])
    })
}