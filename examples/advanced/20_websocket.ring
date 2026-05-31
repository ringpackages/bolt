# WebSocket - Real-Time Communication
# Run: ring 20_websocket.ring

load "bolt.ring"

new Bolt() {
    port = 3000
    
    @get("/", func {
        $bolt.html('<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>WebSocket Test</title>
    <style>
        :root { --bg: #0f0f1a; --surface-card: rgba(255,255,255,0.05); --surface-hover: rgba(255,255,255,0.08); --text: #f1f5f9; --text-secondary: #94a3b8; --accent: #6366f1; --accent-hover: #818cf8; --accent-glow: rgba(99,102,241,0.25); --success: #10b981; --success-glow: rgba(16,185,129,0.2); --error: #ef4444; --glass-border: rgba(255,255,255,0.08); --glass-border-hover: rgba(255,255,255,0.15); --radius: 16px; --radius-sm: 10px; --transition: 0.25s cubic-bezier(0.4, 0, 0.2, 1); --font: Inter, system-ui, -apple-system, sans-serif; }
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { font-family: var(--font); background: var(--bg); background-image: radial-gradient(ellipse 80% 60% at 50% -20%, rgba(99,102,241,0.1), transparent), radial-gradient(ellipse 60% 50% at 80% 80%, rgba(16,185,129,0.05), transparent); color: var(--text); padding: 40px 20px; max-width: 800px; margin: 0 auto; min-height: 100vh; line-height: 1.6; -webkit-font-smoothing: antialiased; }
        h1 { font-size: 28px; font-weight: 700; letter-spacing: -0.5px; margin-bottom: 8px; }
        h2 { font-size: 18px; font-weight: 600; letter-spacing: -0.3px; }
        .subtitle { color: var(--text-secondary); margin-bottom: 32px; font-size: 15px; }
        .card { background: var(--surface-card); backdrop-filter: blur(12px); -webkit-backdrop-filter: blur(12px); border: 1px solid var(--glass-border); border-radius: var(--radius); padding: 24px; margin-bottom: 18px; transition: all var(--transition); position: relative; overflow: hidden; }
        .card::before { content: ""; position: absolute; top: 0; left: 0; right: 0; height: 1px; background: linear-gradient(90deg, transparent, rgba(255,255,255,0.05), transparent); }
        .card:hover { border-color: var(--glass-border-hover); background: var(--surface-hover); box-shadow: 0 8px 32px rgba(0,0,0,0.3); transform: translateY(-1px); }
        .card h2 { margin-bottom: 16px; }
        .form-row { display: flex; gap: 12px; margin-bottom: 12px; }
        input, button { padding: 10px 14px; border-radius: var(--radius-sm); font-size: 14px; font-family: inherit; }
        input { flex: 1; background: rgba(255,255,255,0.04); border: 1px solid var(--glass-border); color: var(--text); transition: border-color var(--transition), box-shadow var(--transition); }
        input::placeholder { color: rgba(148,163,184,0.4); }
        input:focus { outline: none; border-color: rgba(99,102,241,0.5); box-shadow: 0 0 0 3px rgba(99,102,241,0.1); }
        button { background: var(--accent); color: #fff; border: none; cursor: pointer; font-weight: 600; transition: all var(--transition); box-shadow: 0 4px 14px rgba(99,102,241,0.2); }
        button:hover { background: var(--accent-hover); transform: translateY(-1px); box-shadow: 0 6px 20px rgba(99,102,241,0.35); }
        button:active { transform: translateY(0); }
        button.danger { background: var(--error); box-shadow: 0 4px 14px rgba(239,68,68,0.2); }
        button.danger:hover { background: #dc2626; }
        .status { display: inline-flex; align-items: center; gap: 6px; font-size: 14px; margin-bottom: 16px; color: var(--text-secondary); }
        .dot { width: 8px; height: 8px; border-radius: 50%; background: var(--error); }
        .dot.active { background: var(--success); box-shadow: 0 0 8px var(--success-glow); }
        #output { background: rgba(255,255,255,0.03); border: 1px solid var(--glass-border); border-radius: var(--radius-sm); padding: 12px; max-height: 300px; overflow-y: auto; font-family: monospace; font-size: 13px; }
        #output p { padding: 4px 0; border-bottom: 1px solid var(--glass-border); }
        #output p:last-child { border-bottom: none; }
        .msg-error { color: var(--error); }
        .msg-success { color: var(--success); font-weight: 600; }
    </style>
</head>
<body>
    <h1>WebSocket Test</h1>
    <p class="subtitle">Real-time bidirectional communication</p>

    <div class="card">
        <div class="status"><span id="dot" class="dot"></span> <span id="status">Disconnected</span></div>
        <div class="form-row">
            <input type="text" id="message" placeholder="Type a message...">
            <button onclick="sendMessage()">Send</button>
            <button class="danger" onclick="disconnect()">Disconnect</button>
        </div>
        <div id="output"></div>
    </div>

    <script>
        const output = document.getElementById("output");
        const dot = document.getElementById("dot");
        const statusEl = document.getElementById("status");

        function log(text, cls) {
            const p = document.createElement("p");
            if (cls) p.className = cls;
            p.textContent = text;
            output.appendChild(p);
            output.scrollTop = output.scrollHeight;
        }

        const ws = new WebSocket(`ws://${window.location.host}/ws`);

        ws.onopen = () => {
            dot.classList.add("active");
            statusEl.textContent = "Connected";
            log("Connected to server!", "msg-success");
        };

        ws.onmessage = (e) => log("Received: " + e.data);

        ws.onclose = () => {
            dot.classList.remove("active");
            statusEl.textContent = "Disconnected";
            log("Disconnected from server", "msg-error");
        };

        ws.onerror = () => log("Connection error", "msg-error");

        function sendMessage() {
            const msg = document.getElementById("message").value;
            if (!msg.trim()) return;
            if (ws.readyState !== WebSocket.OPEN) { log("Not connected. Message not sent.", "msg-error"); return; }
            ws.send(msg);
            document.getElementById("message").value = "";
        }

        function disconnect() { ws.close(); }

        document.getElementById("message").addEventListener("keypress", (e) => {
            if (e.key === "Enter") sendMessage();
        });
    </script>

    <div class="card">
        <h2>Test with wscat</h2>
        <p>Connect using wscat: <code>wscat -c ws://localhost:3000/ws</code></p>
    </div>
</body>
</html>
        ')
    })
    
    @ws("/ws",
        func {
            id = $bolt.wsClientId()
            ? "Client connected: " + id
            $bolt.wsSendTo(id, "Welcome! Your ID: " + id)
            $bolt.wsBroadcast("User " + id + " joined")
        },
        func {
            id = $bolt.wsClientId()
            msg = $bolt.wsEventMessage()
            ? "Received from " + id + ": " + msg
            
            # Echo back to all connected clients
            $bolt.wsBroadcast("Echo: " + msg)
            
            ? "Connection count: " + $bolt.wsConnectionCount()
        },
        func {
            id = $bolt.wsClientId()
            ? "Client disconnected: " + id
            $bolt.wsBroadcast("User " + id + " left")
        }
    )
}
