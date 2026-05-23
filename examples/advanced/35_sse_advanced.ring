# Advanced SSE - Params Filtering, Events, Max Subscribers
# Run: ring 35_sse_advanced.ring
# Demonstrates: sseBroadcastParams, sseBroadcastEventParams,
#               sseFilterParams, sseMaxSubscribers

load "bolt.ring"

new Bolt() {
    port = 3000

    @sse("/events/global")
    @sse("/events/sports")
    @sse("/events/news")

    sseMaxSubscribers(100)
    sseFilterParams("/events/sports")
    sseFilterParams("/events/news")

    @get("/health", func {
        $bolt.json([:status = "ok"])
    })

    @post("/broadcast/global", func {
        data = $bolt.jsonBody()
        n = $bolt.sseBroadcast("/events/global", data[:message])
        $bolt.json([:sent = n, :target = "global"])
    })

    @post("/broadcast/sports", func {
        data = $bolt.jsonBody()
        cEvent = data[:event]
        cSport = data[:sport]
        n = $bolt.sseBroadcastEventParams("/events/sports", cEvent, data[:message], [:sport = cSport])
        $bolt.json([:sent = n, :target = "sports", :event = cEvent])
    })

    @post("/broadcast/news", func {
        data = $bolt.jsonBody()
        cEvent = data[:event]
        cCategory = data[:category]
        n = $bolt.sseBroadcastEventParams("/events/news", cEvent, data[:headline], [:category = cCategory])
        $bolt.json([:sent = n, :target = "news", :event = cEvent])
    })

    @post("/broadcast/filtered", func {
        data = $bolt.jsonBody()
        cChannel = data[:channel]
        cPath = "/events/" + cChannel
        cEvent = data[:event]
        aParams = [:sport = data[:sport]]
        n = $bolt.sseBroadcastEventParams(cPath, cEvent, data[:message], aParams)
        $bolt.json([:sent = n, :channel = cChannel])
    })

    @get("/", func {
        cSubscribe = `curl -N http://localhost:3000/events/global
curl -N "http://localhost:3000/events/sports?sport=football"
curl -N "http://localhost:3000/events/news?category=world"`

        cBroadcast = `curl -X POST http://localhost:3000/broadcast/global \
  -H "Content-Type: application/json" \
  -d '{"message": "Hello everyone!"}'

curl -X POST http://localhost:3000/broadcast/sports \
  -H "Content-Type: application/json" \
  -d '{"event": "goal", "sport": "football", "message": "Goal scored!"}'

curl -X POST http://localhost:3000/broadcast/news \
  -H "Content-Type: application/json" \
  -d '{"event": "breaking", "category": "world", "headline": "Breaking news!"}'

curl -X POST http://localhost:3000/broadcast/filtered \
  -H "Content-Type: application/json" \
  -d '{"channel": "sports", "event": "update", "sport": "football", "message": "Match update!"}'`

        $bolt.renderFile("./templates/layout.html", [
            :title = "Bolt - Advanced SSE",
            :subtitle = "Params filtering, events, max subscribers",
            :sections = [
                [:title = "SSE Endpoints", :items = [
                    "/events/global - All subscribers receive broadcasts",
                    "/events/sports - Sports updates (filtered by sport param)",
                    "/events/news - News updates (filtered by category param)"
                ]],
                [:title = "Broadcast Endpoints", :items = [
                    "POST /broadcast/global   -> Broadcast to all global subscribers",
                    "POST /broadcast/sports   -> Broadcast sports event with params",
                    "POST /broadcast/news     -> Broadcast news event with params",
                    "POST /broadcast/filtered -> Broadcast to filtered subscribers"
                ]],
                [:title = "Configuration", :code = `sseMaxSubscribers(100)   -> Max 100 subscribers per route
sseFilterParams()        -> Enable param-based filtering
sseBroadcastEventParams() -> Broadcast named event with params`],
                [:title = "Test with curl", :subsections = [
                    [:title = "Subscribe to SSE streams (run in separate terminals)", :code = cSubscribe],
                    [:title = "Broadcast messages", :code = cBroadcast]
                ]]
            ]
        ])
    })
}
