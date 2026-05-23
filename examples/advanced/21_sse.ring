# Server-Sent Events (SSE) - Broadcast Pattern
# Run: ring 21_sse.ring
# Open: http://localhost:3000
# Test: curl -N http://localhost:3000/events

load "bolt.ring"

new Bolt() {
    port = 3000
    
    # SSE endpoints - clients subscribe here
    @sse("/events")
    @sse("/json-events")
    @sse("/stats")
    
    # Trigger broadcasts from routes
    @post("/broadcast", func {
        cData = "Event at " + timeList()[17]
        $bolt.sseBroadcast("/events", cData)
        $bolt.json([:sent = cData])
    })
    
    @post("/broadcast/json", func {
        cData = '{"count": ' + random(100) + ', "timestamp": ' + $bolt.unixtime() + ', "message": "Update"}'
        $bolt.sseBroadcastEvent("/json-events", "update", cData)
        $bolt.json([:sent = cData])
    })
    
    @post("/broadcast/stats", func {
        nMemory = random(100) + 50
        nCpu = random(80) + 10
        cData = '{"memory": ' + nMemory + ', "cpu": ' + nCpu + ', "timestamp": ' + $bolt.unixtime() + '}'
        $bolt.sseBroadcastEvent("/stats", "stats", cData)
        $bolt.json([:sent = cData])
    })
    
    # Web page with SSE client
    @get("/", func {
        $bolt.html('<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Server-Sent Events Demo</title>
    <style>
        :root { --bg: #0f0f1a; --surface-card: rgba(255,255,255,0.05); --surface-hover: rgba(255,255,255,0.08); --text: #f1f5f9; --text-secondary: #94a3b8; --accent: #6366f1; --accent-hover: #818cf8; --success: #10b981; --error: #ef4444; --glass-border: rgba(255,255,255,0.08); --glass-border-hover: rgba(255,255,255,0.15); --radius: 16px; --radius-sm: 10px; --transition: 0.25s cubic-bezier(0.4, 0, 0.2, 1); --font: Inter, system-ui, -apple-system, sans-serif; }
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { font-family: var(--font); background: var(--bg); background-image: radial-gradient(ellipse 80% 60% at 50% -20%, rgba(99,102,241,0.1), transparent), radial-gradient(ellipse 60% 50% at 80% 80%, rgba(16,185,129,0.05), transparent); color: var(--text); padding: 40px 20px; max-width: 800px; margin: 0 auto; min-height: 100vh; line-height: 1.6; -webkit-font-smoothing: antialiased; }
        h1 { font-size: 28px; font-weight: 700; letter-spacing: -0.5px; margin-bottom: 8px; }
        h2 { font-size: 18px; font-weight: 600; letter-spacing: -0.3px; }
        .subtitle { color: var(--text-secondary); margin-bottom: 32px; font-size: 15px; }
        .card { background: var(--surface-card); backdrop-filter: blur(12px); -webkit-backdrop-filter: blur(12px); border: 1px solid var(--glass-border); border-radius: var(--radius); padding: 24px; margin-bottom: 18px; transition: all var(--transition); position: relative; overflow: hidden; }
        .card::before { content: ""; position: absolute; top: 0; left: 0; right: 0; height: 1px; background: linear-gradient(90deg, transparent, rgba(255,255,255,0.05), transparent); }
        .card:hover { border-color: var(--glass-border-hover); background: var(--surface-hover); box-shadow: 0 8px 32px rgba(0,0,0,0.3); transform: translateY(-1px); }
        .card h2 { margin-bottom: 16px; }
        .btn-row { display: flex; gap: 8px; margin-bottom: 12px; flex-wrap: wrap; }
        button { padding: 10px 14px; border-radius: var(--radius-sm); font-size: 14px; background: var(--accent); color: #fff; border: none; cursor: pointer; font-weight: 600; transition: all var(--transition); box-shadow: 0 4px 14px rgba(99,102,241,0.2); }
        button:hover { background: var(--accent-hover); transform: translateY(-1px); box-shadow: 0 6px 20px rgba(99,102,241,0.35); }
        button:active { transform: translateY(0); }
        button.secondary { background: rgba(255,255,255,0.06); color: var(--text); border: 1px solid var(--glass-border); box-shadow: none; }
        button.secondary:hover { background: rgba(255,255,255,0.1); border-color: var(--glass-border-hover); }
        button.danger { background: var(--error); box-shadow: 0 4px 14px rgba(239,68,68,0.2); }
        button.danger:hover { background: #dc2626; }
        .log { background: rgba(255,255,255,0.03); border: 1px solid var(--glass-border); border-radius: var(--radius-sm); padding: 12px; min-height: 80px; max-height: 200px; overflow-y: auto; font-family: monospace; font-size: 13px; }
        .log .entry { padding: 4px 0; border-bottom: 1px solid var(--glass-border); }
        .log .entry:last-child { border-bottom: none; }
        .log .entry.success { color: var(--success); font-weight: 600; }
        .log .entry.error { color: var(--error); }
        .log .entry.muted { color: var(--text-secondary); }
    </style>
</head>
<body>
    <h1>Server-Sent Events Demo</h1>
    <p class="subtitle">Broadcast pattern with named events</p>

    <div class="card">
        <h2>Simple Events</h2>
        <div class="btn-row">
            <button onclick="startEvents()">Subscribe</button>
            <button class="secondary" onclick="triggerEvent()">Trigger Broadcast</button>
            <button class="danger" onclick="stopEvents()">Unsubscribe</button>
        </div>
        <div id="events" class="log"></div>
    </div>

    <div class="card">
        <h2>JSON Events</h2>
        <div class="btn-row">
            <button onclick="startJsonEvents()">Subscribe</button>
            <button class="secondary" onclick="triggerJsonEvent()">Trigger Broadcast</button>
        </div>
        <div id="json-events" class="log"></div>
    </div>

    <div class="card">
        <h2>Live Server Stats</h2>
        <div class="btn-row">
            <button onclick="startStats()">Subscribe</button>
            <button class="secondary" onclick="triggerStats()">Trigger Broadcast</button>
        </div>
        <div id="stats" class="log"></div>
    </div>

    <script>
        let es1, es2, es3;

        function log(id, text, cls) {
            const div = document.getElementById(id);
            const d = document.createElement("div");
            d.className = "entry" + (cls ? " " + cls : "");
            d.textContent = text;
            div.appendChild(d);
            div.scrollTop = div.scrollHeight;
        }

        function startEvents() {
            const div = document.getElementById("events");
            div.innerHTML = "";
            log("events", "Subscribed, waiting for broadcasts...");
            es1 = new EventSource("/events");
            es1.onmessage = (e) => log("events", e.data);
            es1.onerror = () => log("events", "Connection closed", "error");
        }

        function triggerEvent() {
            fetch("/broadcast", { method: "POST" })
                .then(r => log("events", r.ok ? "Broadcast triggered" : "Failed: " + r.status, r.ok ? "success" : "error"))
                .catch(e => log("events", "Error: " + e.message, "error"));
        }

        function stopEvents() {
            if (es1) es1.close();
            log("events", "Unsubscribed", "muted");
        }

        function startJsonEvents() {
            const div = document.getElementById("json-events");
            div.innerHTML = "";
            log("json-events", "Subscribed, waiting for broadcasts...");
            es2 = new EventSource("/json-events");
            es2.addEventListener("update", (e) => {
                const d = JSON.parse(e.data);
                log("json-events", "Count: " + d.count + ", Message: " + d.message);
            });
            es2.onerror = () => log("json-events", "Connection error", "error");
        }

        function triggerJsonEvent() {
            fetch("/broadcast/json", { method: "POST" })
                .then(r => log("json-events", r.ok ? "JSON broadcast triggered" : "Failed: " + r.status, r.ok ? "success" : "error"))
                .catch(e => log("json-events", "Error: " + e.message, "error"));
        }

        function startStats() {
            const div = document.getElementById("stats");
            div.innerHTML = "";
            log("stats", "Subscribed, waiting for broadcasts...");
            es3 = new EventSource("/stats");
            es3.addEventListener("stats", (e) => {
                const d = JSON.parse(e.data);
                div.querySelector(".entry:last-child")?.remove();
                log("stats", "Memory: " + d.memory + "%  |  CPU: " + d.cpu + "%  |  " + new Date(d.timestamp * 1000).toLocaleTimeString());
            });
            es3.onerror = () => log("stats", "Connection error", "error");
        }

        function triggerStats() {
            fetch("/broadcast/stats", { method: "POST" })
                .then(r => log("stats", r.ok ? "Stats broadcast triggered" : "Failed: " + r.status, r.ok ? "success" : "error"))
                .catch(e => log("stats", "Error: " + e.message, "error"));
        }
    </script>
</body>
</html>
        ')
    })
}
