# Session Security - Regeneration, Secure Cookies
# Run: ring 36_session_security.ring
# Demonstrates: regenerateSession, forceSecureCookies, clearSession

load "bolt.ring"

new Bolt() {
    port = 3000
    forceSecureCookies()

    @get("/health", func {
        $bolt.json([:status = "ok"])
    })

    @get("/", func {
        cLogin = `curl -c cookies.txt -X POST http://localhost:3000/login \
  -H "Content-Type: application/json" \
  -d '{"username": "alice"}'`

        $bolt.renderFile("./templates/layout.html", [
            :title = "Bolt - Session Security",
            :subtitle = "Regeneration, secure cookies, session clearing",
            :sections = [
                [:title = "Endpoints", :items = [
                    "POST /login - Login (creates session, regenerates ID)",
                    "GET /profile - View session data (requires login)",
                    "POST /regenerate - Regenerate session ID (prevents fixation)",
                    "GET /session-info - View session details",
                    "POST /logout - Logout (clears session)",
                    "GET /force-secure - Check secure cookie flag"
                ]],
                [:title = "Note", :text = "forceSecureCookies() is enabled - all session cookies get the Secure flag."],
                [:title = "Test with curl", :subsections = [
                    [:title = "Login (session is created, ID regenerated)", :code = cLogin],
                    [:title = "View profile (uses session cookie)", :code = "curl -b cookies.txt http://localhost:3000/profile"],
                    [:title = "Regenerate session ID (prevents fixation)", :code = "curl -b cookies.txt -c cookies.txt -X POST http://localhost:3000/regenerate"],
                    [:title = "View session info", :code = "curl -b cookies.txt http://localhost:3000/session-info"],
                    [:title = "Logout (clears session)", :code = "curl -b cookies.txt -c cookies.txt -X POST http://localhost:3000/logout"],
                    [:title = "Check secure cookie flag", :code = "curl -b cookies.txt http://localhost:3000/force-secure"]
                ]]
            ]
        ])
    })

    @post("/login", func {
        data = $bolt.jsonBody()
        if data[:username] = "" || isNull(data[:username]) {
            $bolt.badRequest("Username required")
            return
        }

        $bolt.setSession("user", data[:username])
        $bolt.setSession("role", "member")
        $bolt.regenerateSession()
        $bolt.json([:success = true, :message = "Logged in with regenerated session"])
    })

    @get("/profile", func {
        cUser = $bolt.getSession("user")
        if cUser = "" || isNull(cUser) {
            $bolt.unauthorized()
            return
        }
        $bolt.json([
            :user = cUser,
            :role = $bolt.getSession("role")
        ])
    })

    @post("/regenerate", func {
        cUser = $bolt.getSession("user")
        if cUser = "" || isNull(cUser) {
            $bolt.unauthorized()
            return
        }
        $bolt.regenerateSession()
        $bolt.json([:success = true, :message = "Session ID regenerated - old session invalidated"])
    })

    @get("/session-info", func {
        $bolt.json([
            :user = $bolt.getSession("user"),
            :role = $bolt.getSession("role"),
            :requestId = $bolt.requestId()
        ])
    })

    @post("/logout", func {
        $bolt.clearSession()
        $bolt.json([:success = true, :message = "Session cleared"])
    })

    @get("/force-secure", func {
        $bolt.json([
            :secureCookies = true,
            :note = "forceSecureCookies() forces Secure flag on all session cookies"
        ])
    })
}