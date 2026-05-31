load "bolt.ring"

new Bolt() {
    cPort = sysget("BOLT_TEST_PORT")
    if cPort = "" { cPort = "3000" }
    port = number(cPort)

    enableCors()
    corsOrigin("*")
    enableCompression()

    @get("/health", func {
        $bolt.json([:status = "ok"])
    })

    @get("/data", func {
        $bolt.json([:message = "hello"])
    })

    @get("/cors-specific", func {
        $bolt.corsOrigin("https://example.com")
        $bolt.json([:cors = "specific"])
    })

    @get("/cors-disabled", func {
        $bolt.disableCors()
        $bolt.json([:cors = "disabled"])
    })

    @get("/no-compress", func {
        $bolt.disableCompression()
        $bolt.json([:message = "no compress"])
    })
}
