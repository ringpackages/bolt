# CORS, Rate Limiting & Security Headers
# Run: ring 23_cors_security.ring

load "bolt.ring"

new Bolt() {
    port = 3000
    
    # Enable CORS for specific origins
    corsOrigin("http://localhost:8080")
    corsOrigin("https://example.com")
    
    # Or enable for all origins (development only!)
    enableCors()
    
    # Rate limiting: 10 requests per 60 seconds
    $bolt.rateLimit(10, 60)
    
    # Enable logging
    enableLogging()
    
    # Add security headers to all responses
    @before(func {
        # Prevent clickjacking
        $bolt.setHeader("X-Frame-Options", "DENY")
        
        # XSS protection
        $bolt.setHeader("X-Content-Type-Options", "nosniff")
        $bolt.setHeader("X-XSS-Protection", "1; mode=block")
        
        # HSTS (force HTTPS)
        $bolt.setHeader("Strict-Transport-Security", "max-age=31536000; includeSubDomains")
        
        # Content Security Policy - allow inline scripts/styles for demo UI
        $bolt.setHeader("Content-Security-Policy", "default-src 'self'; script-src 'self' 'unsafe-inline'; style-src 'self' 'unsafe-inline'")
        
        # Referrer policy
        $bolt.setHeader("Referrer-Policy", "strict-origin-when-cross-origin")
        
        ? "[Security] " + $bolt.method() + " " + $bolt.path()
    })
    
    # Test endpoint
    @get("/api/data", func {
        $bolt.json([
            :message = "This endpoint has CORS enabled",
            :timestamp = $bolt.unixtime()
        ])
    })

    # Rate-limited endpoint
    @get("/api/limited", func {
        if not $bolt.checkRateLimit()
            $bolt.jsonWithStatus(429, [
                :error = "Rate limit exceeded",
                :limit = "10 requests per 60 seconds",
                :retryAfter = 60
            ])
            return
        ok

        $bolt.json([
            :message = "This endpoint is rate-limited",
            :limit = "10 requests per 60 seconds"
        ])
    })

    # Disable CORS (re-enable with enableCors())
    @get("/cors/off", func {
        $bolt.disableCors()
        $bolt.json([:cors = false, :message = "CORS disabled"])
    })

    @get("/cors/on", func {
        $bolt.enableCors()
        $bolt.json([:cors = true, :message = "CORS enabled"])
    })
    
    # Check security headers
    # curl -i http://localhost:3000/security-check
    @get("/security-check", func {
        $bolt.html('<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Security Headers Check</title>
    <style>
        :root { --bg: #0f0f1a; --surface: rgba(255,255,255,0.05); --text: #f1f5f9; --text-secondary: #94a3b8; --accent: #6366f1; --border: rgba(255,255,255,0.08); --radius: 16px; --radius-sm: 10px; --transition: 0.25s cubic-bezier(0.4, 0, 0.2, 1); --font: Inter, system-ui, -apple-system, sans-serif; }
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { font-family: var(--font); background: var(--bg); background-image: radial-gradient(ellipse 80% 60% at 50% -20%, rgba(99,102,241,0.1), transparent), radial-gradient(ellipse 60% 50% at 80% 80%, rgba(16,185,129,0.05), transparent); color: var(--text); padding: 40px 20px; max-width: 800px; margin: 0 auto; min-height: 100vh; line-height: 1.6; -webkit-font-smoothing: antialiased; }
        h1 { font-size: 28px; font-weight: 700; letter-spacing: -0.5px; margin-bottom: 8px; }
        h2 { font-size: 18px; font-weight: 600; letter-spacing: -0.3px; }
        .subtitle { color: var(--text-secondary); margin-bottom: 32px; font-size: 15px; }
        .card { background: var(--surface); backdrop-filter: blur(12px); -webkit-backdrop-filter: blur(12px); border: 1px solid var(--border); border-radius: var(--radius); padding: 24px; margin-bottom: 18px; position: relative; overflow: hidden; }
        .card::before { content: ""; position: absolute; top: 0; left: 0; right: 0; height: 1px; background: linear-gradient(90deg, transparent, rgba(255,255,255,0.05), transparent); }
        .card h2 { margin-bottom: 16px; }
        code { background: rgba(255,255,255,0.04); padding: 2px 6px; border-radius: 4px; font-size: 13px; font-family: monospace; }
        pre { background: rgba(255,255,255,0.04); padding: 12px; border-radius: var(--radius-sm); overflow-x: auto; font-size: 13px; margin: 12px 0; font-family: monospace; }
        ul { list-style: none; padding: 0; }
        li { padding: 8px 0; border-bottom: 1px solid var(--border); font-family: monospace; font-size: 14px; }
        li:last-child { border-bottom: none; }
    </style>
</head>
<body>
    <h1>Security Headers Check</h1>
    <p class="subtitle">Use <code>curl -i</code> to inspect response headers</p>

    <div class="card">
        <h2>Test Command</h2>
        <pre>curl -i http://localhost:3000/security-check</pre>
    </div>

    <div class="card">
        <h2>Expected Headers</h2>
        <ul>
            <li>X-Frame-Options: DENY</li>
            <li>X-Content-Type-Options: nosniff</li>
            <li>X-XSS-Protection: 1; mode=block</li>
            <li>Strict-Transport-Security</li>
            <li>Content-Security-Policy</li>
            <li>Referrer-Policy</li>
        </ul>
    </div>
</body>
</html>
        ')
    })
    
    # CORS test page
    @get("/", func {
        $bolt.html('<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>CORS & Security Test</title>
    <style>
        :root { --bg: #0f0f1a; --surface: rgba(255,255,255,0.05); --text: #f1f5f9; --text-secondary: #94a3b8; --accent: #6366f1; --accent-hover: #818cf8; --success: #10b981; --error: #ef4444; --warning: #f59e0b; --border: rgba(255,255,255,0.08); --radius: 16px; --radius-sm: 10px; --transition: 0.25s cubic-bezier(0.4, 0, 0.2, 1); --font: Inter, system-ui, -apple-system, sans-serif; }
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { font-family: var(--font); background: var(--bg); background-image: radial-gradient(ellipse 80% 60% at 50% -20%, rgba(99,102,241,0.1), transparent), radial-gradient(ellipse 60% 50% at 80% 80%, rgba(16,185,129,0.05), transparent); color: var(--text); padding: 40px 20px; max-width: 800px; margin: 0 auto; min-height: 100vh; line-height: 1.6; -webkit-font-smoothing: antialiased; }
        h1 { font-size: 28px; font-weight: 700; letter-spacing: -0.5px; margin-bottom: 8px; }
        h2 { font-size: 18px; font-weight: 600; letter-spacing: -0.3px; }
        .subtitle { color: var(--text-secondary); margin-bottom: 32px; font-size: 15px; }
        .card { background: var(--surface); backdrop-filter: blur(12px); -webkit-backdrop-filter: blur(12px); border: 1px solid var(--border); border-radius: var(--radius); padding: 24px; margin-bottom: 18px; transition: all var(--transition); position: relative; overflow: hidden; }
        .card::before { content: ""; position: absolute; top: 0; left: 0; right: 0; height: 1px; background: linear-gradient(90deg, transparent, rgba(255,255,255,0.05), transparent); }
        .card h2 { margin-bottom: 8px; }
        .card p { color: var(--text-secondary); font-size: 14px; margin-bottom: 16px; }
        button { padding: 10px 14px; border-radius: var(--radius-sm); font-size: 14px; background: var(--accent); color: #fff; border: none; cursor: pointer; font-weight: 600; transition: all var(--transition); box-shadow: 0 4px 14px rgba(99,102,241,0.2); }
        button:hover { background: var(--accent-hover); transform: translateY(-1px); box-shadow: 0 6px 20px rgba(99,102,241,0.35); }
        button:active { transform: translateY(0); }
        a.btn { display: inline-block; padding: 10px 14px; border-radius: var(--radius-sm); font-size: 14px; background: var(--accent); color: #fff; text-decoration: none; font-weight: 600; transition: all var(--transition); box-shadow: 0 4px 14px rgba(99,102,241,0.2); }
        a.btn:hover { background: var(--accent-hover); transform: translateY(-1px); box-shadow: 0 6px 20px rgba(99,102,241,0.35); }
        #result { margin-top: 12px; font-family: monospace; font-size: 13px; }
        #result .row { padding: 6px 0; }
        #result .ok { color: var(--success); }
        #result .warn { color: var(--warning); }
        #result .err { color: var(--error); }
    </style>
</head>
<body>
    <h1>CORS & Security Headers</h1>
    <p class="subtitle">Rate limiting, CORS, and security header demonstration</p>

    <div class="card">
        <h2>Rate Limiting</h2>
        <p>Click rapidly (more than 10 times in 60 seconds) to trigger the limit.</p>
        <button onclick="testRateLimit()">Test Rate Limit</button>
        <div id="result"></div>
    </div>

    <div class="card">
        <h2>Security Headers</h2>
        <p>View all response headers returned by the server.</p>
        <a class="btn" href="/security-check">Check Security Headers</a>
    </div>

    <script>
        let count = 0;
        async function testRateLimit() {
            const div = document.getElementById("result");
            count++;
            try {
                const res = await fetch("/api/limited");
                const data = await res.json();
                if (res.ok) {
                    div.innerHTML += "<div class=\"row ok\">Request #" + count + ": " + JSON.stringify(data) + "</div>";
                } else if (res.status === 429) {
                    div.innerHTML += "<div class=\"row warn\">Request #" + count + ": Rate limit exceeded (429)</div>";
                } else {
                    div.innerHTML += "<div class=\"row err\">Request #" + count + ": Error " + res.status + "</div>";
                }
            } catch (e) {
                div.innerHTML += "<div class=\"row err\">Request #" + count + ": Network error - " + e.message + "</div>";
            }
        }
    </script>

    <div class="card">
        <h2>Test with curl</h2>
        <p>Test rate limit:</p>
        <pre>curl http://localhost:3000/api/limited</pre>
        <p>Disable CORS:</p>
        <pre>curl http://localhost:3000/cors/off</pre>
        <p>Enable CORS:</p>
        <pre>curl http://localhost:3000/cors/on</pre>
        <p>Check security headers:</p>
        <pre>curl -i http://localhost:3000/security-check</pre>
    </div>
</body>
</html>
        ')
    })
}
