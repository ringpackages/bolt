# Logging - log levels, structured logging
# Run: ring 17_logging.ring

load "bolt.ring"

env = new Env()
cAdminKey = env.getOr("ADMIN_KEY", "change-me-admin-key")
if env.getVar("ADMIN_KEY") = ""
    ? "WARNING: ADMIN_KEY not set, using insecure default"
ok

new Bolt() {
    port = 3000

    enableLogging()

    @before(func {
        $bolt.logWithLevel("[" + $bolt.method() + "] " + $bolt.path() + " from " + $bolt.clientIp(), "info")
    })

    @after(func {
        $bolt.logWithLevel("[" + $bolt.method() + "] " + $bolt.path() + " completed", "info")
    })

    @get("/", func {
        $bolt.log("Homepage visited")
        $bolt.html(`
<h1>Logging Example</h1>
<h3>Check server console for log output</h3>
<pre>
# Default log
curl http://localhost:3000/

# Warn level log
curl http://localhost:3000/warn

# Error level log
curl http://localhost:3000/error

# Info level log
curl http://localhost:3000/info

# Change log level
curl http://localhost:3000/set-level/warn

# Disable logging
curl http://localhost:3000/disable

# Enable logging
curl http://localhost:3000/enable
</pre>
        `)
    })

    @get("/warn", func {
        $bolt.logWithLevel("Disk space running low", "warn")
        $bolt.json([:logged = "warn"])
    })

    @get("/error", func {
        $bolt.logWithLevel("Database connection failed", "error")
        $bolt.json([:logged = "error"])
    })

    @get("/info", func {
        $bolt.logWithLevel("User authenticated successfully", "info")
        $bolt.json([:logged = "info"])
    })

    @get("/set-level/:level", func {
        # Require admin auth header to change log level
        cHeaderKey = $bolt.header("X-Admin-Key")
        if cHeaderKey != cAdminKey
            $bolt.forbidden()
            return
        ok

        cLevel = $bolt.param("level")
        $bolt.setLogLevel(cLevel)
        $bolt.json([
            :message = "Log level changed",
            :level = cLevel
        ])
    })

    @get("/disable", func {
        # Require admin auth
        cHeaderKey = $bolt.header("X-Admin-Key")
        if cHeaderKey != cAdminKey
            $bolt.forbidden()
            return
        ok

        $bolt.disableLogging()
        $bolt.json([:logging = false, :message = "Logging disabled"])
    })

    @get("/enable", func {
        # Require admin auth
        cHeaderKey = $bolt.header("X-Admin-Key")
        if cHeaderKey != cAdminKey
            $bolt.forbidden()
            return
        ok

        $bolt.enableLogging()
        $bolt.json([:logging = true, :message = "Logging enabled"])
    })
}
