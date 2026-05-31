# WebSocket Control - Event Abort, Dropped Count, Rate Limits
# Run: ring 40_websocket_control.ring
# Demonstrates: wsEventAbort, wsDroppedCount, setWsMaxConnections, setWsMaxPerIp, setWsMessageRateLimit

load "bolt.ring"

new Bolt() {
    port = 3000

    setWsMaxConnections(50)
    setWsMaxPerIp(10)
    setWsMessageRateLimit(100)

    @get("/health", func {
        $bolt.json([:status = "ok"])
    })

    @ws("/ws/chat", :ws_chat_connect, :ws_chat_message, :ws_chat_disconnect)
    @ws("/ws/abort-test", :ws_abort_connect, :ws_abort_message, "")
    @ws("/ws/echo", "", :ws_echo_message, "")

    @get("/ws/stats", func {
        $bolt.json([
            :connections = $bolt.wsConnectionCount(),
            :dropped = $bolt.wsDroppedCount(),
            :maxConnections = 50,
            :maxPerIp = 10,
            :messageRateLimit = "100/s"
        ])
    })

    @get("/ws/clients", func {
        $bolt.json([:clients = $bolt.wsClientList()])
    })

    @get("/", func {
        $bolt.renderFile("./templates/layout.html", [
            :title = "Bolt - WebSocket Control",
            :subtitle = "Event abort, dropped count, rate limits",
            :sections = [
                [:title = "Test with curl", :subsections = [
                    [:title = "Health check", :code = "curl http://localhost:3000/health"],
                    [:title = "WebSocket stats", :code = "curl http://localhost:3000/ws/stats"],
                    [:title = "List connected clients", :code = "curl http://localhost:3000/ws/clients"]
                ]],
                [:title = "WebSocket Endpoints", :items = [
                    "/ws/chat - Normal chat with connect/message/disconnect",
                    "/ws/abort-test - Before middleware aborts the event",
                    "/ws/echo - Echo server"
                ]],
                [:title = "Configuration", :code = `setWsMaxConnections(50)     -> Max 50 total connections
setWsMaxPerIp(10)           -> Max 10 connections per IP
setWsMessageRateLimit(100)   -> 100 messages/second per client
wsEventAbort()              -> Abort event from before middleware
wsDroppedCount()            -> Count of dropped messages`],
                [:title = "Test with wscat", :subsections = [
                    [:title = "Connect to chat", :code = "wscat -c ws://localhost:3000/ws/chat"],
                    [:title = "Connect to echo", :code = "wscat -c ws://localhost:3000/ws/echo"]
                ]]
            ]
        ])
    })
}

func ws_chat_connect()
    id = $bolt.wsClientId()
    $bolt.wsRoomJoin("chat", id)
    $bolt.wsRoomBroadcast("chat", id + " joined")

func ws_chat_message()
    id = $bolt.wsClientId()
    msg = $bolt.wsEventMessage()
    $bolt.wsRoomBroadcast("chat", id + ": " + msg)

func ws_chat_disconnect()
    id = $bolt.wsClientId()
    $bolt.wsRoomLeave("chat", id)
    $bolt.wsRoomBroadcast("chat", id + " left")

func ws_abort_connect()
    $bolt.wsEventAbort()

func ws_abort_message()
    id = $bolt.wsClientId()
    $bolt.wsSendTo(id, "should not see this - event was aborted")

func ws_echo_message()
    msg = $bolt.wsEventMessage()
    id = $bolt.wsClientId()
    $bolt.wsSendTo(id, "echo:" + msg)