load "bolt.ring"

new Bolt() {
    cPort = sysget("BOLT_TEST_PORT")
    if cPort = "" { cPort = "3000" }
    port = number(cPort)

    setWsMaxConnections(10)
    setWsMaxPerIp(5)
    setWsMessageRateLimit(50)

    @get("/health", func {
        $bolt.json([:status = "ok"])
    })

    @ws("/ws/chat", :chat_on_connect, :chat_on_message, :chat_on_disconnect)
    @ws("/ws/echo", "", :echo_on_message, "")
    @ws("/ws/binary-echo", "", :binary_echo_on_message, "")
    @ws("/ws/context/:roomId", :context_on_connect, :context_on_message, :context_on_disconnect)
    @ws("/ws/binary-room", :binroom_on_connect, :binroom_on_message, "")
    @ws("/ws/abort-test", :abort_on_connect, :abort_on_message, "")

    @get("/ws/stats", func {
        $bolt.json([
            :connections = $bolt.wsConnectionCount(),
            :room_count = $bolt.wsRoomCount("lobby"),
            :dropped = $bolt.wsDroppedCount()
        ])
    })

    @get("/ws/clients", func {
        $bolt.json([:clients = $bolt.wsClientList()])
    })

    @get("/ws/room-members", func {
        $bolt.json([:members = $bolt.wsRoomMembers("lobby")])
    })

    @get("/ws/broadcast", func {
        n = $bolt.wsBroadcast("global announcement")
        $bolt.json([:sent_to = n])
    })

    @post("/ws/close-client", func {
        id = $bolt.query("id")
        ok = $bolt.wsCloseClient(id)
        $bolt.json([:closed = ok])
    })

    @before(func {
        $bolt.setHeader("X-Request-Id", $bolt.requestId())
    })
}

func chat_on_connect()
    id = $bolt.wsClientId()
    $bolt.wsRoomJoin("lobby", id)

func chat_on_message()
    msg = $bolt.wsEventMessage()
    id = $bolt.wsClientId()
    $bolt.wsRoomBroadcast("lobby", id + ": " + msg)

func chat_on_disconnect()
    id = $bolt.wsClientId()
    $bolt.wsRoomLeave("lobby", id)

func echo_on_message()
    msg = $bolt.wsEventMessage()
    id = $bolt.wsClientId()
    $bolt.wsSendTo(id, "echo:" + msg)

func binary_echo_on_message()
    isBin = $bolt.wsEventIsBinary()
    if isBin {
        bdata = $bolt.wsEventBinary()
        id = $bolt.wsClientId()
        $bolt.wsSendBinaryTo(id, bdata)
    else
        msg = $bolt.wsEventMessage()
        id = $bolt.wsClientId()
        $bolt.wsSendTo(id, "text:" + msg)
    }

func context_on_connect()
    id = $bolt.wsClientId()
    eventType = $bolt.wsEventType()
    roomId = $bolt.wsParam("roomId")
    path = $bolt.wsEventPath()
    $bolt.wsSendTo(id, "connected:" + eventType + ":" + roomId + ":" + path)
    $bolt.wsRoomJoin(roomId, id)

func context_on_message()
    msg = $bolt.wsEventMessage()
    id = $bolt.wsClientId()
    eventType = $bolt.wsEventType()
    roomId = $bolt.wsParam("roomId")
    $bolt.wsSendTo(id, "msg:" + eventType + ":" + roomId + ":" + msg)

func context_on_disconnect()
    id = $bolt.wsClientId()
    roomId = $bolt.wsParam("roomId")
    $bolt.wsRoomLeave(roomId, id)

func binroom_on_connect()
    id = $bolt.wsClientId()
    $bolt.wsRoomJoin("binroom", id)

func binroom_on_message()
    id = $bolt.wsClientId()
    isBin = $bolt.wsEventIsBinary()
    if isBin {
        bdata = $bolt.wsEventBinary()
        $bolt.wsRoomBroadcastBinary("binroom", bdata)
    else
        msg = $bolt.wsEventMessage()
        $bolt.wsRoomBroadcast("binroom", id + ": " + msg)
    }

func abort_on_connect()
    $bolt.wsEventAbort()

func abort_on_message()
    $bolt.wsSendTo($bolt.wsClientId(), "should-not-see-this")
