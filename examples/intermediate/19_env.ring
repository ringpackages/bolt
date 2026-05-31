# Environment Variables
# Run: ring 19_env.ring

load "bolt.ring"

if !fexists(".env")
    write(".env", "PORT=3000" + char(10) + "APP_ENV=development" + char(10))
ok

env = new Env()

new Bolt() {
    port = 3000

    @get("/env/:key", func {
        cKey = $bolt.param("key")
        cUpper = upper(cKey)
        if substr(cUpper, "SECRET") or substr(cUpper, "PASSWORD") or substr(cUpper, "TOKEN") or substr(cUpper, "CREDENTIALS") or substr(cUpper, "PRIVATE") or substr(cUpper, "ENCRYPTION")
            $bolt.jsonWithStatus(403, [:error = "Access denied"])
            return
        ok
        cValue = env.getOr(cKey, "")
        $bolt.json([:key = cKey, :value = cValue])
    })

    @get("/env/:key/:default", func {
        cKey = $bolt.param("key")
        cDefault = $bolt.param("default")
        cUpper = upper(cKey)
        if substr(cUpper, "SECRET") or substr(cUpper, "PASSWORD") or substr(cUpper, "TOKEN") or substr(cUpper, "CREDENTIALS") or substr(cUpper, "PRIVATE") or substr(cUpper, "ENCRYPTION")
            $bolt.jsonWithStatus(403, [:error = "Access denied"])
            return
        ok
        cValue = env.getOr(cKey, cDefault)
        $bolt.json([:key = cKey, :value = cValue, :default = cDefault])
    })

    @post("/env", func {
        data = $bolt.jsonBody()
        $bolt.json([:note = "Use reload", :key = data[:key], :value = data[:value]])
    })

    @post("/env/reload", func {
        env.loadEnv()
        $bolt.json([:reloaded = true])
    })

    @get("/config", func {
        $bolt.json([
            :app_env = env.getOr("APP_ENV", "development"),
            :port = env.getOr("PORT", "3000"),
            :note = "Secrets not exposed"
        ])
    })

    @get("/", func {
        $bolt.html("<h1>Environment Variables</h1>")
    })
}
