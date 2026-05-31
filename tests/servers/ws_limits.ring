load "bolt.ring"

new Bolt() {
    cPort = sysget("BOLT_TEST_PORT")
    if cPort = "" { cPort = "3000" }
    port = number(cPort)

    setWsMaxConnections(5)
    setWsMaxPerIp(3)
    setWsMessageRateLimit(5)

    @get("/health", func {
        $bolt.json([:status = "ok"])
    })

    @ws("/ws/chat", :ws_chat_connect, :ws_chat_message, :ws_chat_disconnect)

    @get("/ws/stats", func {
        $bolt.json([
            :connections = $bolt.wsConnectionCount(),
            :dropped = $bolt.wsDroppedCount()
        ])
    })
}

func ws_chat_connect()
    id = $bolt.wsClientId()
    $bolt.wsRoomJoin("lobby", id)

func ws_chat_message()
    msg = $bolt.wsEventMessage()
    id = $bolt.wsClientId()
    $bolt.wsSendTo(id, "echo:" + msg)

func ws_chat_disconnect()
    id = $bolt.wsClientId()
    $bolt.wsRoomLeave("lobby", id)
