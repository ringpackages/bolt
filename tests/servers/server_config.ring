load "bolt.ring"


new Bolt() {
    cPort = sysget("BOLT_TEST_PORT")
    if cPort = "" { cPort = "3000" }
    port = number(cPort)

    setBodyLimit(100)
    setTimeout(30000)
    forceSecureCookies()
    setMultipartFieldCountLimit(5)
    setMultipartFieldSizeLimit(1024)
    setSessionCapacity(100)
    setSessionTTL(3600)
    setCacheCapacity(100)
    setCacheTTL(300)

    @get("/health", func {
        $bolt.json([:status = "ok"])
    })

    @post("/body-check", func {
        $bolt.json([:received = $bolt.body()])
    })

    @post("/body-oversized", func {
        $bolt.json([:received = $bolt.body()])
    })

    @post("/multipart-limit", func {
        $bolt.json([:fields = $bolt.formField("field1"), :files = $bolt.filesCount()])
    })

    @get("/session/config-test", func {
        $bolt.setSession("test_key", "test_value")
        val = $bolt.getSession("test_key")
        $bolt.json([:key = "test_key", :value = val])
    })

    @get("/cache/config-test", func {
        $bolt.cacheSet("cfg_key", "cfg_value")
        val = $bolt.cacheGet("cfg_key")
        $bolt.json([:key = "cfg_key", :value = val])
    })

    @get("/json-decode", func {
        result = $bolt.jsonDecode('{"name":"bolt","version":1}')
        $bolt.json([:decoded = result])
    })

    @get("/render-template-return", func {
        result = $bolt.renderTemplate("Hello {{ name }}!", [:name = "World"])
        $bolt.send(result)
    })

    @get("/openapi-spec", func {
        $bolt.setOpenApiSpec('{"openapi":"3.0.0","info":{"title":"Custom","version":"2.0.0"}}')
        $bolt.json([:set = true])
    })

    @get("/request/info", func {
        $bolt.json([
            :method = $bolt.method(),
            :path = $bolt.path(),
            :ip = $bolt.clientIp()
        ])
    })

    @get("/cache/capacity-test", func {
        for i = 1 to 150 {
            $bolt.cacheSet("key_" + i, "value_" + i)
        }
        count = 0
        for i = 1 to 150 {
            if $bolt.cacheGet("key_" + i) != "" { count++ }
        }
        $bolt.json([:capacity = count])
    })

    @get("/session/capacity-test", func {
        for i = 1 to 150 {
            $bolt.setSession("session_key_" + i, "value_" + i)
        }
        val = $bolt.getSession("session_key_100")
        $bolt.json([:found = val != ""])
    })
}
