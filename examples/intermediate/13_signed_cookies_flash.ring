# Signed Cookies & Flash Messages
# Run: ring 13_signed_cookies_flash.ring

load "bolt.ring"

new Bolt() {
    port = 3000

    setCookieSecret("my-super-secret-key-32chars!")

    # Set a signed cookie
    # curl -i -c cookies.txt http://localhost:3000/set-signed
    @get("/set-signed", func {
        $bolt.setSignedCookie("user_id", "12345")
        $bolt.setSignedCookie("session_token", "abc123def456")
        $bolt.send("Signed cookies set! Check response headers.")
    })

    # Read a signed cookie
    # curl -b cookies.txt http://localhost:3000/get-signed
    @get("/get-signed", func {
        cUserId = $bolt.getSignedCookie("user_id")
        cToken = $bolt.getSignedCookie("session_token")

        if cUserId != ""
            $bolt.json([
                :valid = true,
                :user_id = cUserId,
                :session_token = cToken
            ])
        else
            $bolt.jsonWithStatus(401, [
                :valid = false,
                :error = "Invalid or tampered cookie"
            ])
        ok
    })

    # Cookie with options (HttpOnly, Secure, SameSite)
    # curl -i http://localhost:3000/set-secure-cookie
    @get("/set-secure-cookie", func {
        $bolt.setCookieEx("session", "abc123", "Path=/; Max-Age=3600; HttpOnly; Secure; SameSite=Strict")
        $bolt.send("Secure cookie set with options!")
    })

    # Delete a cookie
    # curl -i http://localhost:3000/delete-cookie
    @get("/delete-cookie", func {
        $bolt.deleteCookie("user_id")
        $bolt.send("Cookie deleted!")
    })

    # Set a flash message then redirect
    # curl -i http://localhost:3000/action
    @get("/action", func {
        $bolt.setFlash("success", "Action completed successfully!")
        $bolt.setFlash("info", "This is an info message")
        $bolt.redirect("/result")
    })

    # Read flash messages (one-time, auto-cleared after read)
    # curl -b cookies.txt http://localhost:3000/result
    @get("/result", func {
        aMessages = []

        if $bolt.hasFlash("success")
            cMsg = $bolt.getFlash("success")
            aMessages + [:type = "success", :text = cMsg]
        ok

        if $bolt.hasFlash("info")
            cMsg = $bolt.getFlash("info")
            aMessages + [:type = "info", :text = cMsg]
        ok

        if len(aMessages) > 0
            $bolt.json([
                :has_messages = true,
                :messages = aMessages,
                :note = "These messages are auto-cleared after reading"
            ])
        else
            $bolt.json([
                :has_messages = false,
                :message = "No flash messages. Visit /action first."
            ])
        ok
    })

    # Delete a session key
    # curl http://localhost:3000/delete-session
    @get("/delete-session", func {
        $bolt.setSession("temp_key", "temp_value")
        $bolt.deleteSession("temp_key")
        cValue = $bolt.getSession("temp_key")

        $bolt.json([
            :deleted = true,
            :value_after_delete = cValue,
            :note = "Session key deleted, returns empty string"
        ])
    })

    @get("/", func {
        $bolt.html("
<h1>Signed Cookies & Flash Messages</h1>
<h3>Try these:</h3>
<pre>
# Set signed cookies (saves session cookie)
curl -i -c cookies.txt http://localhost:3000/set-signed

# Read signed cookies (uses saved cookie)
curl -b cookies.txt http://localhost:3000/get-signed

# Secure cookie with options
curl -i http://localhost:3000/set-secure-cookie

# Delete cookie
curl -i http://localhost:3000/delete-cookie

# Flash messages (set + redirect, saves session cookie)
curl -i -c cookies.txt http://localhost:3000/action

# Read flash messages (uses saved session cookie from /action)
curl -b cookies.txt http://localhost:3000/result

# Delete session key
curl http://localhost:3000/delete-session
</pre>
        ")
    })
}
