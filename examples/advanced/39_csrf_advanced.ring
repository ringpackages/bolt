# Advanced CSRF - Auto Verification
# Run: ring 39_csrf_advanced.ring
# Demonstrates: csrfAutoVerify, csrfToken, verifyCsrf

load "bolt.ring"

new Bolt() {
    port = 3000

    enableCsrf("my-csrf-secret-key-32chars-min!!")
    csrfAutoVerify()

    @get("/health", func {
        $bolt.json([:status = "ok"])
    })

    @get("/", func {
        cToken = $bolt.csrfToken()
        cGetToken = `curl -c cookies.txt http://localhost:3000/api/csrf-token`
        cSubmit = `TOKEN=$(curl -s -b cookies.txt http://localhost:3000/api/csrf-token | jq -r '.csrfToken')
curl -b cookies.txt -X POST http://localhost:3000/api/submit \
  -H "X-CSRF-Token: $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"data":"test"}'`
        cNoToken = `curl -b cookies.txt -X POST http://localhost:3000/api/submit \
  -H "Content-Type: application/json" \
  -d '{"data":"test"}'`
        cManual = `TOKEN=$(curl -s -b cookies.txt http://localhost:3000/api/csrf-token | jq -r '.csrfToken')
curl -b cookies.txt -X POST http://localhost:3000/api/manual-verify \
  -H "X-CSRF-Token: $TOKEN"`
        cBlocked = `curl -b cookies.txt -X POST http://localhost:3000/api/no-csrf`

        $bolt.renderFile("./templates/layout.html", [
            :title = "Bolt - Advanced CSRF",
            :subtitle = "Auto verification, token generation, manual verify",
            :sections = [
                [:title = "Configuration", :code = `enableCsrf("secret")  -> Enable CSRF with signing secret
csrfAutoVerify()       -> Auto-verify POST/PUT/DELETE/PATCH`],
                [:title = "Endpoints", :items = [
                    "GET /api/csrf-token - Get a fresh CSRF token",
                    "POST /api/submit - Submit form (auto-verified by csrfAutoVerify)",
                    "POST /api/manual-verify - Manual CSRF verification via verifyCsrf()",
                    "POST /api/no-csrf - Will be BLOCKED without CSRF token"
                ]],
                [:title = "Test with curl", :subsections = [
                    [:title = "Get CSRF token (saves session cookie)", :code = cGetToken],
                    [:title = "Submit with token (uses same session cookie - will succeed)", :code = cSubmit],
                    [:title = "Submit WITHOUT token (will be blocked by csrfAutoVerify)", :code = cNoToken],
                    [:title = "Manual verification", :code = cManual],
                    [:title = "Without CSRF (blocked)", :code = cBlocked]
                ]],
                [:title = "Current CSRF Token", :text = cToken]
            ]
        ])
    })

    @get("/api/csrf-token", func {
        cToken = $bolt.csrfToken()
        $bolt.json([:csrfToken = cToken, :note = "Include this in X-CSRF-Token header for POST/PUT/DELETE/PATCH"])
    })

    @post("/api/submit", func {
        data = $bolt.jsonBody()
        $bolt.json([:success = true, :data = data, :message = "CSRF auto-verified - token was valid"])
    })

    @post("/api/manual-verify", func {
        cToken = $bolt.header("X-CSRF-Token")
        if $bolt.verifyCsrf(cToken) {
            $bolt.json([:success = true, :message = "CSRF token manually verified"])
        else
            $bolt.jsonWithStatus(403, [:error = "Invalid CSRF token"])
        ok
    })

    @post("/api/no-csrf", func {
        $bolt.json([:success = true, :message = "This should not be reached without CSRF token"])
    })

    @get("/form", func {
        cToken = $bolt.csrfToken()
        $bolt.html(`
<!DOCTYPE html>
<html>
<head><title>CSRF Form</title></head>
<body>
    <h1>CSRF Protected Form</h1>
    <form method="POST" action="/api/submit">
        <input type="hidden" name="_csrf" value="` + cToken + `">
        <input type="text" name="data" placeholder="Enter data">
        <button type="submit">Submit</button>
    </form>
    <p>csrfAutoVerify() checks: X-CSRF-Token header, _csrf form field, or _csrf query param</p>
</body>
</html>
        `)
    })
}