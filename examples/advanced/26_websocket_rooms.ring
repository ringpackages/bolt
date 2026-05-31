# WebSocket Rooms & Binary Data
# Run: ring 26_websocket_rooms.ring

load "bolt.ring"

new Bolt() {
    port = 3000

    @get("/", func {
        $bolt.html('<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>WebSocket Rooms</title>
    <style>
        :root { --bg: #0f0f1a; --surface: rgba(255,255,255,0.05); --text: #f1f5f9; --text-secondary: #94a3b8; --accent: #6366f1; --success: #10b981; --error: #ef4444; --border: rgba(255,255,255,0.08); --radius: 16px; --radius-sm: 10px; --font: Inter, system-ui, -apple-system, sans-serif; }
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { font-family: var(--font); background: var(--bg); color: var(--text); padding: 40px 20px; max-width: 900px; margin: 0 auto; min-height: 100vh; line-height: 1.6; -webkit-font-smoothing: antialiased; }
        h1 { font-size: 28px; font-weight: 700; margin-bottom: 8px; }
        h2 { font-size: 18px; font-weight: 600; }
        .subtitle { color: var(--text-secondary); margin-bottom: 32px; }
        .grid { display: grid; grid-template-columns: 1fr 1fr; gap: 18px; margin-bottom: 18px; }
        .card { background: var(--surface); border: 1px solid var(--border); border-radius: var(--radius); padding: 24px; }
        .card h2 { margin-bottom: 12px; }
        select, input, button { padding: 8px 12px; border-radius: var(--radius-sm); font-size: 14px; font-family: inherit; }
        select, input { background: rgba(255,255,255,0.04); border: 1px solid var(--border); color: var(--text); width: 100%; margin-bottom: 8px; }
        input:focus, select:focus { outline: none; border-color: rgba(99,102,241,0.5); }
        button { background: var(--accent); color: #fff; border: none; cursor: pointer; font-weight: 600; width: 100%; margin-bottom: 4px; transition: all 0.2s; }
        button:hover { background: #818cf8; }
        .log { background: rgba(255,255,255,0.03); border: 1px solid var(--border); border-radius: var(--radius-sm); padding: 12px; max-height: 250px; overflow-y: auto; font-family: monospace; font-size: 13px; margin-top: 12px; }
        .log p { padding: 3px 0; border-bottom: 1px solid var(--border); }
        .log p:last-child { border-bottom: none; }
        .stats { display: flex; gap: 12px; margin-top: 12px; }
        .stat { background: rgba(255,255,255,0.04); border: 1px solid var(--border); border-radius: var(--radius-sm); padding: 8px 14px; font-size: 13px; }
        .stat strong { color: var(--accent); }
    </style>
</head>
<body>
    <h1>WebSocket Rooms & Binary</h1>
    <p class="subtitle">Room-based chat with binary data support</p>

    <div class="grid">
        <div class="card">
            <h2>Join a Room</h2>
            <select id="room"><option value="general">general</option><option value="support">support</option><option value="dev">dev</option></select>
            <input type="text" id="msg" placeholder="Type a message...">
            <button onclick="sendMsg()">Send to Room</button>
            <button onclick="sendBinary()">Send Binary</button>
            <button onclick="leaveRoom()">Leave Room</button>
            <div class="stats">
                <span class="stat">Room: <strong id="roomName">-</strong></span>
                <span class="stat">Members: <strong id="roomCount">0</strong></span>
                <span class="stat">Connections: <strong id="connCount">0</strong></span>
            </div>
        </div>
        <div class="card">
            <h2>Room Messages</h2>
            <div id="output" class="log"></div>
        </div>
    </div>

    <div class="card">
        <h2>Server Stats</h2>
        <button onclick="refreshStats()">Refresh Stats</button>
        <div id="statsOutput" class="log"></div>
    </div>

    <script>
        const output = document.getElementById("output");
        let currentRoom = "";
        let ws = null;

        function log(text) {
            const p = document.createElement("p");
            p.textContent = text;
            output.appendChild(p);
            output.scrollTop = output.scrollHeight;
        }

        function connect() {
            ws = new WebSocket(`ws://${window.location.host}/ws`);
            ws.onopen = () => { log("Connected to server"); joinRoom(); };
            ws.onmessage = (e) => log("Received: " + e.data);
            ws.onclose = () => log("Disconnected");
            ws.onerror = () => log("Connection error");
        }

        function joinRoom() {
            currentRoom = document.getElementById("room").value;
            document.getElementById("roomName").textContent = currentRoom;
            ws.send(JSON.stringify({action: "join", room: currentRoom}));
        }

        function sendMsg() {
            const msg = document.getElementById("msg").value;
            if (!msg.trim() || !ws || ws.readyState !== WebSocket.OPEN) return;
            ws.send(JSON.stringify({action: "message", room: currentRoom, text: msg}));
            document.getElementById("msg").value = "";
        }

        function sendBinary() {
            if (!ws || ws.readyState !== WebSocket.OPEN) return;
            const arr = new Uint8Array([72, 101, 108, 108, 111]);
            ws.send(arr.buffer);
            log("Sent binary data: [72,101,108,108,111] = \"Hello\"");
        }

        function leaveRoom() {
            if (!ws || ws.readyState !== WebSocket.OPEN || !currentRoom) return;
            ws.send(JSON.stringify({action: "leave", room: currentRoom}));
            log("Left room: " + currentRoom);
            currentRoom = "";
            document.getElementById("roomName").textContent = "-";
        }

        async function refreshStats() {
            try {
                const res = await fetch("/stats");
                const data = await res.json();
                document.getElementById("statsOutput").innerHTML = "";
                for (const rd of data.room_data) {
                    const p = document.createElement("p");
                    p.textContent = "Room " + rd.name + ": " + rd.count + " members - " + JSON.stringify(rd.members);
                    document.getElementById("statsOutput").appendChild(p);
                    if (rd.name === currentRoom) {
                        document.getElementById("roomCount").textContent = rd.count;
                    }
                }
                document.getElementById("connCount").textContent = data.connections;
            } catch(e) {}
        }

        document.getElementById("msg").addEventListener("keypress", (e) => {
            if (e.key === "Enter") sendMsg();
        });

        document.getElementById("room").addEventListener("change", () => {
            if (currentRoom) leaveRoom();
            setTimeout(joinRoom, 200);
        });

        connect();
        setInterval(refreshStats, 3000);
    </script>

    <div class="card">
        <h2>Test with wscat</h2>
        <p>Connect to main WebSocket:</p>
        <pre>wscat -c ws://localhost:3000/ws</pre>
        <p>Connect to named room:</p>
        <pre>wscat -c ws://localhost:3000/room/general</pre>
        <p>View room stats:</p>
        <pre>curl http://localhost:3000/stats</pre>
    </div>
</body>
</html>
        ')
    })

    @ws("/ws",
        func {
            id = $bolt.wsClientId()
            $bolt.wsSendTo(id, $bolt.jsonEncode([:type = "welcome", :id = id, :path = $bolt.wsEventPath()]))
        },
        func {
            id = $bolt.wsClientId()
            cEventType = $bolt.wsEventType()
            msg = $bolt.wsEventMessage()

            if $bolt.wsEventIsBinary()
                cBinary = $bolt.wsEventBinary()
                $bolt.wsSendTo(id, "Received binary (" + len(cBinary) + " bytes base64)")
                $bolt.wsSendBinaryTo(id, cBinary)
            else
                data = $bolt.jsonDecode(msg)
                if data[:action] = "join"
                    $bolt.wsRoomJoin(data[:room], id)
                    $bolt.wsRoomBroadcast(data[:room], "User " + id + " joined room")
                    $bolt.wsSendTo(id, "Joined room: " + data[:room])
                elseif data[:action] = "message"
                    $bolt.wsRoomBroadcast(data[:room], "[" + data[:room] + "] " + id + ": " + data[:text])
                    $bolt.wsRoomBroadcastBinary(data[:room], $bolt.jsonEncode([:room = data[:room], :user = id, :text = data[:text]]))
                elseif data[:action] = "leave"
                    $bolt.wsRoomLeave(data[:room], id)
                    $bolt.wsRoomBroadcast(data[:room], "User " + id + " left room")
                elseif data[:action] = "close"
                    $bolt.wsCloseClient(id)
                ok
            ok
        },
        func {
            id = $bolt.wsClientId()
            $bolt.wsBroadcast("User " + id + " disconnected")
        }
    )

    @get("/stats", func {
        aRooms = ["general", "support", "dev"]
        aLines = []
        aRoomData = []
        for cRoom in aRooms
            nCount = $bolt.wsRoomCount(cRoom)
            aMembers = $bolt.wsRoomMembers(cRoom)
            Add(aLines, "Room '" + cRoom + "': " + nCount + " members - " + $bolt.jsonEncode(aMembers))
            add(aRoomData, [
                :name = cRoom,
                :count = nCount,
                :members = aMembers
            ])
        next

        aClients = $bolt.wsClientList()

        $bolt.json([
            :connections = $bolt.wsConnectionCount(),
            :client_list = aClients,
            :rooms = aLines,
            :room_data = aRoomData
        ])
    })

    # WebSocket with route params
    @ws("/room/:name",
        func {
            id = $bolt.wsClientId()
            cRoom = $bolt.wsParam("name")
            $bolt.wsRoomJoin(cRoom, id)
            $bolt.wsSendTo(id, "Joined param room: " + cRoom)
            $bolt.wsRoomBroadcast(cRoom, "User " + id + " joined " + cRoom)
        },
        func {
            id = $bolt.wsClientId()
            cRoom = $bolt.wsParam("name")
            msg = $bolt.wsEventMessage()
            $bolt.wsRoomBroadcast(cRoom, "[" + cRoom + "] " + id + ": " + msg)
        },
        func {
            id = $bolt.wsClientId()
            cRoom = $bolt.wsParam("name")
            $bolt.wsRoomLeave(cRoom, id)
            $bolt.wsRoomBroadcast(cRoom, "User " + id + " left " + cRoom)
        }
    )
}
