# Cookies & Sessions
# Run: ring 07_cookies_sessions.ring

load "bolt.ring"

new Bolt() {
    port = 3000

    # Set a cookie
    # curl -i http://localhost:3000/set-cookie
    @get("/set-cookie", func {
        $bolt.setCookie("username", "BoltUser")
        $bolt.setCookie("theme", "dark")

        $bolt.send("Cookies set! Check response headers.")
    })

    # Read cookies
    # curl http://localhost:3000/get-cookie -H "Cookie: username=BoltUser; theme=dark"
    @get("/get-cookie", func {
        cUsername = $bolt.cookie("username")
        cTheme = $bolt.cookie("theme")

        $bolt.json([
            :username = cUsername,
            :theme = cTheme
        ])
    })

    # Sessions - increment counter
    # curl -b cookies.txt -c cookies.txt http://localhost:3000/counter
    @get("/counter", func {
        cCount = $bolt.getSession("counter")

        if cCount = ""
            cCount = "0"
        ok

        nCount = 0 + cCount
        nCount++

        $bolt.setSession("counter", "" + nCount)

        $bolt.json([
            :counter = nCount,
            :message = "Counter incremented"
        ])
    })

    # Login - set session
    # curl -i -X POST http://localhost:3000/login -d "username=alice"
    @post("/login", func {
        cBody = $bolt.body()
        ? "Login attempt: " + cBody

        $bolt.setSession("user", "alice")
        $bolt.setSession("loggedIn", "true")

        $bolt.send("Logged in! Session created.")
    })

    # Check if logged in
    # curl -b cookies.txt http://localhost:3000/profile
    @get("/profile", func {
        cLoggedIn = $bolt.getSession("loggedIn")
        cUser = $bolt.getSession("user")

        if cLoggedIn = "true"
            $bolt.json([
                :authenticated = true,
                :user = cUser
            ])
        else
            $bolt.jsonWithStatus(401, [
                :authenticated = false,
                :error = "Not logged in"
            ])
        ok
    })

    # Logout - clear session
    # curl -b cookies.txt -c cookies.txt http://localhost:3000/logout
    @get("/logout", func {
        $bolt.clearSession()
        $bolt.send("Logged out! Session cleared.")
    })

    @get("/", func {
        $bolt.html("
<h1>Cookies & Sessions Example</h1>
<h3>Try these:</h3>
<pre>
# Set cookies
curl -i http://localhost:3000/set-cookie

# Read cookies (use cookie from above)
curl http://localhost:3000/get-cookie -H 'Cookie: username=BoltUser'

# Session counter (saves session cookie)
curl -c cookies.txt http://localhost:3000/counter
curl -b cookies.txt -c cookies.txt http://localhost:3000/counter  # increments

# Login (saves session cookie)
curl -i -b cookies.txt -c cookies.txt -X POST http://localhost:3000/login -d 'username=alice'

# Check profile (uses saved session cookie)
curl -b cookies.txt http://localhost:3000/profile

# Logout (uses and clears saved session cookie)
curl -b cookies.txt -c cookies.txt http://localhost:3000/logout
</pre>
        ")
    })
}
