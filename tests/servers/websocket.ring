load "bolt.ring"

new Bolt() {
    cPort = sysget("BOLT_TEST_PORT")
    if cPort = "" { cPort = "3000" }
    port = number(cPort)

    @get("/health", func {
        $bolt.json([:status = "ok"])
    })

    @ws("/ws/chat", :ws_chat_connect, :ws_chat_message, :ws_chat_disconnect)
    @ws("/ws/echo", "", :ws_echo_message, "")

    @get("/ws/stats", func {
        $bolt.json([
            :connections = $bolt.wsConnectionCount(),
            :room_count = $bolt.wsRoomCount("lobby")
        ])
    })

    @get("/ws/clients", func {
        $bolt.json([:clients = $bolt.wsClientList()])
    })
}

func ws_chat_connect()
    id = $bolt.wsClientId()
    $bolt.wsRoomJoin("lobby", id)

func ws_chat_message()
    msg = $bolt.wsEventMessage()
    id = $bolt.wsClientId()
    $bolt.wsRoomBroadcast("lobby", id + ": " + msg)

func ws_chat_disconnect()
    id = $bolt.wsClientId()
    $bolt.wsRoomLeave("lobby", id)

func ws_echo_message()
    msg = $bolt.wsEventMessage()
    id = $bolt.wsClientId()
    $bolt.wsSendTo(id, "echo:" + msg)
