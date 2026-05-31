# JWT Authentication - Secure Token-Based Auth
# Run: ring 22_auth_jwt.ring

load "bolt.ring"

hash = new Hash

env = new Env()
cJwtSecret = env.getOr("JWT_SECRET", "change-this-to-a-real-secret-32chars!!")
if env.getVar("JWT_SECRET") = ""
    ? "WARNING: JWT_SECRET not set, using insecure default"
ok

cAdminPass = env.getOr("ADMIN_PASS", "admin123")
cUserPass = env.getOr("USER_PASS", "user123")
if env.getVar("ADMIN_PASS") = "" or env.getVar("USER_PASS") = ""
    ? "WARNING: ADMIN_PASS/USER_PASS not set, using insecure defaults"
ok

cAdminHash = hash.argon2(cAdminPass)
cUserHash = hash.argon2(cUserPass)

aUsers = [
    [:username = "admin", :password_hash = cAdminHash, :role = "admin"],
    [:username = "user", :password_hash = cUserHash, :role = "user"]
]

new Bolt() {
    port = 3000
    
    enableLogging()
    
    # Login endpoint
    # curl -X POST http://localhost:3000/login -H "Content-Type: application/json" -d '{"username":"admin","password":"YOUR_ADMIN_PASS"}'
    @post("/login", func {
        data = $bolt.jsonBody()
        if data = NULL
            $bolt.badRequest("Invalid JSON body")
            return
        ok

        cUsername = data[:username]
        cPassword = data[:password]

        bFound = false
        nMax = len(aUsers)
        for i = 1 to nMax
            if aUsers[i][:username] = cUsername
                if hash.verifyArgon2(cPassword, aUsers[i][:password_hash])
                    bFound = true
                    cToken = $bolt.jwtEncodeExp([
                        :sub = aUsers[i][:username],
                        :role = aUsers[i][:role]
                    ], cJwtSecret, 3600)

                    $bolt.json([
                        :success = true,
                        :token = cToken,
                        :message = "Login successful"
                    ])
                ok
                exit
            ok
        next

        if !bFound
            $bolt.jsonWithStatus(401, [
                :success = false,
                :error = "Invalid credentials"
            ])
        ok
    })
    
    # Protected route - requires valid JWT
    # curl http://localhost:3000/protected -H "Authorization: Bearer YOUR_TOKEN_HERE"
    @get("/protected", func {
        cAuth = $bolt.header("Authorization")
        
        if cAuth = "" or not substr(cAuth, "Bearer ")
            $bolt.jsonWithStatus(401, [
                :error = "No token provided"
            ])
            return
        ok
        
        # Extract token (remove "Bearer " prefix)
        cToken = substr(cAuth, 8)
        
        # Verify token
        if $bolt.jwtVerify(cToken, cJwtSecret)
            aClaims = $bolt.jwtDecode(cToken, cJwtSecret)
            
            $bolt.json([
                :success = true,
                :message = "Access granted",
                :user = aClaims
            ])
        else
            $bolt.jsonWithStatus(401, [
                :error = "Invalid or expired token"
            ])
        ok
    })
    
    # Admin-only route
    @get("/admin", func {
        cAuth = $bolt.header("Authorization")
        
        if cAuth = ""
            $bolt.jsonWithStatus(401, [:error = "No token"])
            return
        ok
        
        cToken = substr(cAuth, 8)
        
        if $bolt.jwtVerify(cToken, cJwtSecret)
            aClaims = $bolt.jwtDecode(cToken, cJwtSecret)

            # Verify role claim
            if aClaims[:role] != "admin"
                $bolt.jsonWithStatus(403, [:error = "Admin role required"])
                return
            ok

            $bolt.json([
                :success = true,
                :message = "Admin access granted",
                :claims = aClaims
            ])
        else
            $bolt.jsonWithStatus(403, [:error = "Forbidden"])
        ok
    })
    
    # Refresh token
    @post("/refresh", func {
        cAuth = $bolt.header("Authorization")
        
        if cAuth = ""
            $bolt.jsonWithStatus(401, [:error = "No token"])
            return
        ok
        
        cToken = substr(cAuth, 8)
        
        if $bolt.jwtVerify(cToken, cJwtSecret)
            # Issue new token
            cNewToken = $bolt.jwtEncodeExp([
                :sub = "admin",
                :role = "admin"
            ], cJwtSecret, 3600)
            
            $bolt.json([
                :success = true,
                :token = cNewToken
            ])
        else
            $bolt.jsonWithStatus(401, [:error = "Invalid token"])
        ok
    })
    
    # Basic Auth endpoints
    # curl -i http://localhost:3000/basic-auth -H "Authorization: Basic YWRtaW46c2VjcmV0"
    @get("/basic-auth", func {
        cAuth = $bolt.header("Authorization")

        if cAuth = "" or left(cAuth, 6) != "Basic "
            $bolt.setHeader("WWW-Authenticate", 'Basic realm="Protected"')
            $bolt.unauthorized()
            return
        ok

        aCreds = $bolt.basicAuthDecode(cAuth)

        if aCreds = NULL
            $bolt.unauthorized()
            return
        ok

        cUser = aCreds[:username]
        cPass = aCreds[:password]

        bFound = false
        nMax = len(aUsers)
        for i = 1 to nMax
            if aUsers[i][:username] = cUser
                if hash.verifyArgon2(cPass, aUsers[i][:password_hash])
                    bFound = true
                    $bolt.json([:authenticated = true, :username = cUser])
                ok
                exit
            ok
        next

        if !bFound
            $bolt.unauthorized()
        ok
    })

    # REMOVED: /basic-encode endpoint exposed credentials in URL/response
    # Use a secure offline tool or base64 command instead:
    # echo -n "user:pass" | base64

    @get("/", func {
        $bolt.html(`<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>JWT Authentication Demo</title>
    <style>
        :root { --bg: #0f0f1a; --surface: rgba(255,255,255,0.05); --text: #f1f5f9; --text-secondary: #94a3b8; --accent: #6366f1; --accent-hover: #818cf8; --success: #10b981; --error: #ef4444; --border: rgba(255,255,255,0.08); --radius: 16px; --radius-sm: 10px; --transition: 0.25s cubic-bezier(0.4, 0, 0.2, 1); --font: Inter, system-ui, -apple-system, sans-serif; }
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { font-family: var(--font); background: var(--bg); background-image: radial-gradient(ellipse 80% 60% at 50% -20%, rgba(99,102,241,0.1), transparent), radial-gradient(ellipse 60% 50% at 80% 80%, rgba(16,185,129,0.05), transparent); color: var(--text); padding: 40px 20px; max-width: 800px; margin: 0 auto; min-height: 100vh; line-height: 1.6; -webkit-font-smoothing: antialiased; }
        h1 { font-size: 28px; font-weight: 700; letter-spacing: -0.5px; margin-bottom: 8px; }
        h2 { font-size: 18px; font-weight: 600; letter-spacing: -0.3px; }
        .subtitle { color: var(--text-secondary); margin-bottom: 32px; font-size: 15px; }
        .card { background: var(--surface); backdrop-filter: blur(12px); -webkit-backdrop-filter: blur(12px); border: 1px solid var(--border); border-radius: var(--radius); padding: 24px; margin-bottom: 18px; transition: all var(--transition); position: relative; overflow: hidden; }
        .card::before { content: ""; position: absolute; top: 0; left: 0; right: 0; height: 1px; background: linear-gradient(90deg, transparent, rgba(255,255,255,0.05), transparent); }
        .card:hover { border-color: rgba(255,255,255,0.15); background: rgba(255,255,255,0.08); box-shadow: 0 8px 32px rgba(0,0,0,0.3); transform: translateY(-1px); }
        .card h2 { margin-bottom: 16px; }
        .form-row { display: flex; gap: 12px; margin-bottom: 12px; flex-wrap: wrap; }
        input, button { padding: 10px 14px; border-radius: var(--radius-sm); font-size: 14px; font-family: inherit; }
        input { flex: 1; min-width: 120px; background: rgba(255,255,255,0.04); border: 1px solid var(--border); color: var(--text); transition: border-color var(--transition), box-shadow var(--transition); }
        input::placeholder { color: rgba(148,163,184,0.4); }
        input:focus { outline: none; border-color: rgba(99,102,241,0.5); box-shadow: 0 0 0 3px rgba(99,102,241,0.1); }
        button { background: var(--accent); color: #fff; border: none; cursor: pointer; font-weight: 600; transition: all var(--transition); box-shadow: 0 4px 14px rgba(99,102,241,0.2); }
        button:hover { background: var(--accent-hover); transform: translateY(-1px); box-shadow: 0 6px 20px rgba(99,102,241,0.35); }
        button:active { transform: translateY(0); }
        button.secondary { background: rgba(255,255,255,0.06); color: var(--text); border: 1px solid var(--border); box-shadow: none; }
        button.secondary:hover { background: rgba(255,255,255,0.1); border-color: rgba(255,255,255,0.15); }
        .result { margin-top: 12px; padding: 14px; border-radius: var(--radius-sm); font-family: monospace; font-size: 13px; white-space: pre-wrap; word-break: break-all; display: none; }
        .result.show { display: block; }
        .result.success { background: rgba(16,185,129,0.08); border: 1px solid rgba(16,185,129,0.2); color: #6ee7b7; }
        .result.error { background: rgba(239,68,68,0.08); border: 1px solid rgba(239,68,68,0.2); color: #fca5a5; }
        .token-box { background: rgba(255,255,255,0.03); border: 1px solid var(--border); padding: 12px; border-radius: var(--radius-sm); font-family: monospace; font-size: 12px; word-break: break-all; margin-top: 12px; display: none; }
        .token-box.show { display: block; }
        .status { display: inline-flex; align-items: center; gap: 6px; font-size: 13px; margin-top: 12px; color: var(--text-secondary); }
        .dot { width: 8px; height: 8px; border-radius: 50%; background: var(--error); }
        .dot.active { background: var(--success); box-shadow: 0 0 8px rgba(16,185,129,0.3); }
    </style>
</head>
<body>
    <h1>JWT Authentication Demo</h1>
    <p class="subtitle">Test JWT encode, decode, verify, and refresh interactively</p>

    <div class="card">
        <h2>1. Login & Get Token</h2>
        <p style="font-size: 13px; color: var(--text-secondary); margin-bottom: 12px;">Credentials: Check the aUsers list in source (demo only)</p>
        <div class="form-row">
            <input type="text" id="loginUser" value="admin" placeholder="Username">
            <input type="password" id="loginPass" value="" placeholder="Password (set via env)">
            <button onclick="doLogin()">Login</button>
        </div>
        <div id="loginResult" class="result"></div>
        <div id="tokenDisplay" class="token-box"></div>
        <div class="status"><span id="authDot" class="dot"></span> <span id="authStatus">Not authenticated</span></div>
    </div>

    <div class="card">
        <h2>2. Access Protected Route</h2>
        <button onclick="testProtected()">Test /protected</button>
        <button class="secondary" onclick="testAdmin()">Test /admin</button>
        <div id="protectedResult" class="result"></div>
    </div>

    <div class="card">
        <h2>3. Refresh Token</h2>
        <button onclick="doRefresh()">Refresh Token</button>
        <div id="refreshResult" class="result"></div>
    </div>

    <div class="card">
        <h2>4. Manual Token Operations</h2>
        <div class="form-row">
            <input type="text" id="manualToken" placeholder="Paste token here..." style="flex: 2;">
            <button class="secondary" onclick="decodeManual()">Decode</button>
            <button class="secondary" onclick="verifyManual()">Verify</button>
        </div>
        <div id="manualResult" class="result"></div>
    </div>

    <script>
        let currentToken = "";

        function showResult(id, text, isSuccess) {
            const el = document.getElementById(id);
            el.textContent = text;
            el.className = "result show " + (isSuccess ? "success" : "error");
        }

        function updateAuthStatus() {
            const dot = document.getElementById("authDot");
            const status = document.getElementById("authStatus");
            if (currentToken) {
                dot.classList.add("active");
                status.textContent = "Authenticated";
            } else {
                dot.classList.remove("active");
                status.textContent = "Not authenticated";
            }
        }

        async function doLogin() {
            const user = document.getElementById("loginUser").value;
            const pass = document.getElementById("loginPass").value;
            try {
                const res = await fetch("/login", {
                    method: "POST",
                    headers: { "Content-Type": "application/json" },
                    body: JSON.stringify({ username: user, password: pass })
                });
                const data = await res.json();
                if (data.token) {
                    currentToken = data.token;
                    document.getElementById("tokenDisplay").textContent = data.token;
                    document.getElementById("tokenDisplay").classList.add("show");
                    document.getElementById("manualToken").value = data.token;
                    showResult("loginResult", "Login successful! Token received.", true);
                } else {
                    showResult("loginResult", "Login failed: " + JSON.stringify(data), false);
                }
            } catch (e) {
                showResult("loginResult", "Error: " + e.message, false);
            }
            updateAuthStatus();
        }

        async function testProtected() {
            if (!currentToken) { showResult("protectedResult", "No token. Login first.", false); return; }
            try {
                const res = await fetch("/protected", { headers: { "Authorization": "Bearer " + currentToken } });
                const data = await res.json();
                showResult("protectedResult", JSON.stringify(data, null, 2), res.ok);
            } catch (e) {
                showResult("protectedResult", "Error: " + e.message, false);
            }
        }

        async function testAdmin() {
            if (!currentToken) { showResult("protectedResult", "No token. Login first.", false); return; }
            try {
                const res = await fetch("/admin", { headers: { "Authorization": "Bearer " + currentToken } });
                const data = await res.json();
                showResult("protectedResult", JSON.stringify(data, null, 2), res.ok);
            } catch (e) {
                showResult("protectedResult", "Error: " + e.message, false);
            }
        }

        async function doRefresh() {
            if (!currentToken) { showResult("refreshResult", "No token to refresh.", false); return; }
            try {
                const res = await fetch("/refresh", { method: "POST", headers: { "Authorization": "Bearer " + currentToken } });
                const data = await res.json();
                if (data.token) {
                    currentToken = data.token;
                    document.getElementById("manualToken").value = data.token;
                    showResult("refreshResult", "Token refreshed! New token:\n" + data.token, true);
                } else {
                    showResult("refreshResult", "Refresh failed: " + JSON.stringify(data), false);
                }
            } catch (e) {
                showResult("refreshResult", "Error: " + e.message, false);
            }
            updateAuthStatus();
        }

        async function decodeManual() {
            const token = document.getElementById("manualToken").value.trim();
            if (!token) { showResult("manualResult", "Enter a token.", false); return; }
            try {
                const parts = token.split(".");
                if (parts.length !== 3) { showResult("manualResult", "Invalid JWT format", false); return; }
                const payload = JSON.parse(atob(parts[1]));
                showResult("manualResult", "Decoded payload:\n" + JSON.stringify(payload, null, 2), true);
            } catch (e) {
                showResult("manualResult", "Decode error: " + e.message, false);
            }
        }

        async function verifyManual() {
            const token = document.getElementById("manualToken").value.trim();
            if (!token) { showResult("manualResult", "Enter a token.", false); return; }
            try {
                const res = await fetch("/protected", { headers: { "Authorization": "Bearer " + token } });
                const data = await res.json();
                showResult("manualResult", "Server verification:\n" + JSON.stringify(data, null, 2), res.ok);
            } catch (e) {
                showResult("manualResult", "Error: " + e.message, false);
            }
        }
    </script>

    <div class="card">
        <h2>Test with curl</h2>
        <p>Login:</p>
        <pre>curl -X POST http://localhost:3000/login -H 'Content-Type: application/json' -d '{"username":"admin","password":"YOUR_ADMIN_PASS"}'</pre>
        <p>Access protected route:</p>
        <pre>curl http://localhost:3000/protected -H 'Authorization: Bearer YOUR_TOKEN'</pre>
        <p>Access admin route:</p>
        <pre>curl http://localhost:3000/admin -H 'Authorization: Bearer YOUR_TOKEN'</pre>
        <p>Refresh token:</p>
        <pre>curl -X POST http://localhost:3000/refresh -H 'Authorization: Bearer YOUR_TOKEN'</pre>
        <p>Basic auth:</p>
        <pre>curl -i http://localhost:3000/basic-auth -H 'Authorization: Basic YWRtaW46c2VjcmV0'</pre>
    </div>
</body>
</html>
        `)
    })
}
