load "bolt.ring"


new Bolt() {
    cPort = sysget("BOLT_TEST_PORT")
    if cPort = "" { cPort = "3000" }
    port = number(cPort)

    enableLogging()
    setLogLevel("info")

    @get("/health", func {
        $bolt.json([:status = "ok"])
    })

    @get("/log", func {
        msg = $bolt.query("msg")
        if msg = "" { msg = "test log message" }
        $bolt.log("User log: " + msg)
        $bolt.json([:logged = msg])
    })

    @get("/log/level", func {
        level = $bolt.query("level")
        msg = $bolt.query("msg")
        if level = "" { level = "info" }
        if msg = "" { msg = "test" }
        $bolt.logWithLevel(msg, level)
        $bolt.json([:logged = 1, :level = level])
    })

    @get("/log/set-level", func {
        level = $bolt.query("level")
        $bolt.setLogLevel(level)
        $bolt.json([:level_set = level])
    })

    @get("/log/disable", func {
        $bolt.disableLogging()
        $bolt.json([:logging_disabled = 1])
    })

    @get("/log/enable", func {
        $bolt.enableLogging()
        $bolt.json([:logging_enabled = 1])
    })
}
