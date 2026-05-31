load "bolt.ring"


new Bolt() {
    cPort = sysget("BOLT_TEST_PORT")
    if cPort = "" { cPort = "3000" }
    port = number(cPort)

    @get("/health", func {
        $bolt.json([:status = "ok"])
    })

    @get("/cache/set", func {
        key = $bolt.query("key")
        value = $bolt.query("value")
        $bolt.cacheSet(key, value)
        $bolt.json([:cached = true, :key = key, :value = value])
    })

    @get("/cache/set-ttl", func {
        key = $bolt.query("key")
        value = $bolt.query("value")
        ttl = number($bolt.query("ttl"))
        $bolt.cacheSetTTL(key, value, ttl)
        $bolt.json([:cached = true, :key = key, :ttl = ttl])
    })

    @get("/cache/get", func {
        key = $bolt.query("key")
        value = $bolt.cacheGet(key)
        $bolt.json([:key = key, :value = value])
    })

    @get("/cache/delete", func {
        key = $bolt.query("key")
        $bolt.cacheDelete(key)
        $bolt.json([:deleted = key])
    })

    @get("/cache/clear", func {
        $bolt.cacheClear()
        $bolt.json([:cleared = true])
    })
}
