load "bolt.ring"


new Bolt() {
    cPort = sysget("BOLT_TEST_PORT")
    if cPort = "" { cPort = "3000" }
    port = number(cPort)

    @get("/health", func {
        $bolt.json([:status = "ok"])
    })

    @before(func {
        $bolt.setHeader("X-Global-Before", "true")
        $bolt.setHeader("X-Request-Id", $bolt.requestId())
    })

    @after(func {
        $bolt.setHeader("X-Global-After", "true")
    })

    @use("namedGlobalMiddleware")

    @get("/secure/data", func {
        $bolt.json([:data = "secret"])
    })
    before("setSecureHeader")

    @get("/secure/audit", func {
        $bolt.json([:audit = "logged"])
    })
    after("auditLog")

    @get("/secure/full", func {
        $bolt.json([:full = "protected"])
    })
    before("setSecureHeader")
    after("auditLog")

    @get("/plain", func {
        $bolt.json([:plain = true])
    })
}

func namedGlobalMiddleware() {
    $bolt.setHeader("X-Named-Global", "executed")
}

func setSecureHeader() {
    $bolt.setHeader("X-Before", "applied")
}

func auditLog() {
    $bolt.setHeader("X-After", "applied")
}
