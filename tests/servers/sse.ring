load "bolt.ring"


new Bolt() {
    cPort = sysget("BOLT_TEST_PORT")
    if cPort = "" { cPort = "3000" }
    port = number(cPort)

    @get("/health", func {
        $bolt.json([:status = "ok"])
    })

    @sse("/events/notifications")

    @sse("/events/filter/:channel")
    sseFilterParams("/events/filter/:channel")

    @post("/events/trigger", func {
        n = $bolt.sseBroadcast("/events/notifications", "test-event")
        $bolt.json([:sent = true, :clients = n])
    })

    @post("/events/named", func {
        n = $bolt.sseBroadcastEvent("/events/notifications", "alert", "important!")
        $bolt.json([:sent = true, :clients = n])
    })

    @post("/events/filter-trigger", func {
        channel = $bolt.query("channel")
        n = $bolt.sseBroadcastParams("/events/filter/" + channel, "filtered-event", [:channel = channel])
        $bolt.json([:sent = true, :clients = n])
    })

    @post("/events/named-filter", func {
        channel = $bolt.query("channel")
        n = $bolt.sseBroadcastEventParams("/events/filter/" + channel, "custom-event", "data", [:channel = channel])
        $bolt.json([:sent = true, :clients = n])
    })

    sseMaxSubscribers(2)

    @sse("/events/limited")

    @post("/events/nonexistent-broadcast", func {
        n = $bolt.sseBroadcast("/events/nonexistent", "data")
        $bolt.json([:sent_to = n])
    })

    @post("/events/filter-nonmatching", func {
        n = $bolt.sseBroadcastParams("/events/filter/sports", "filtered-event", [:channel = "news"])
        $bolt.json([:sent = true, :clients = n])
    })
}
