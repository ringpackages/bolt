load "bolt.ring"

new Bolt() {
    cPort = sysget("BOLT_TEST_PORT")
    if cPort = "" { cPort = "3000" }
    port = number(cPort)

    @get("/health", func {
        $bolt.json([:status = "ok"])
    })

    sseMaxSubscribers(2)

    @sse("/events")

    @get("/broadcast", func {
        n = $bolt.sseBroadcast("/events", "test message")
        $bolt.json([:sent_to = n])
    })
}
