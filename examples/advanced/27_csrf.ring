# CSRF Protection - Cross-Site Request Forgery Prevention
# Run: ring 27_csrf.ring

load "bolt.ring"

new Bolt() {
    port = 3000

    # Load CSRF secret from environment variable
    env = new Env()
    enableCsrf(env.getOr("CSRF_SECRET", "change-me-csrf-secret-32chars!!"))
    if env.getVar("CSRF_SECRET") = ""
        ? "WARNING: CSRF_SECRET not set, using insecure default"
    ok

    # Form with CSRF token
    @get("/form", func {
        cToken = $bolt.csrfToken()
        html = '<form method="POST" action="/submit">
            <input type="hidden" name="_csrf" value="' + cToken + '">
            <label>Name: <input type="text" name="name"></label><br><br>
            <label>Email: <input type="text" name="email"></label><br><br>
            <button type="submit">Submit</button>
        </form>'
        $bolt.html(html)
    })

    # Verify CSRF on submit
    @post("/submit", func {
        cToken = $bolt.formField("_csrf")

        if !$bolt.verifyCsrf(cToken)
            $bolt.forbidden()
            return
        ok

        cName = $bolt.formField("name")
        cEmail = $bolt.formField("email")

        $bolt.json([
            :success = true,
            :name = cName,
            :email = cEmail,
            :csrf_valid = true
        ])
    })

    # API endpoint for checking CSRF
    @post("/api/submit", func {
        cToken = $bolt.formField("_csrf")

        $bolt.json([
            :csrf_valid = $bolt.verifyCsrf(cToken),
            :token_received = cToken
        ])
    })

    # Get a CSRF token for API usage
    @get("/api/csrf-token", func {
        $bolt.json([
            :csrf_token = $bolt.csrfToken(),
            :usage = "Include this token as _csrf field in your form submission"
        ])
    })

    @get("/", func {
        $bolt.renderFile("./templates/layout.html", [
            :title = "Bolt - CSRF Protection",
            :subtitle = "Cross-Site Request Forgery prevention",
            :sections = [
                [:title = "Endpoints", :items = [
                    "GET /form - Form with CSRF token",
                    "POST /submit - Verify CSRF on form submit",
                    "POST /api/submit - API endpoint for checking CSRF",
                    "GET /api/csrf-token - Get a CSRF token for API usage"
                ]],
                [:title = "Test with curl", :subsections = [
                    [:title = "Get form with CSRF token (saves session cookie)", :code = "curl -c cookies.txt http://localhost:3000/form"],
                    [:title = "Get CSRF token for API usage", :code = "curl -c cookies.txt http://localhost:3000/api/csrf-token"],
                    [:title = "Submit form with valid CSRF token (uses session cookie)", :code = "curl -b cookies.txt -X POST http://localhost:3000/api/submit -F '_csrf=YOUR_TOKEN_HERE'"],
                    [:title = "Submit without token (will fail with 403)", :code = "curl -b cookies.txt -X POST http://localhost:3000/submit -F 'name=Alice' -F 'email=alice@example.com'"]
                ]]
            ]
        ])
    })
}
