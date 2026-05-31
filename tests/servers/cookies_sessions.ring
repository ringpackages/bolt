load "bolt.ring"


new Bolt() {
    cPort = sysget("BOLT_TEST_PORT")
    if cPort = "" { cPort = "3000" }
    port = number(cPort)

    @get("/health", func {
        $bolt.json([:status = "ok"])
    })

    @get("/cookies/set", func {
        $bolt.setCookie("session_id", $bolt.uuid())
        $bolt.setCookieEx("prefs", "dark", "Path=/; Max-Age=86400")
        $bolt.json([:message = "Cookies set!"])
    })

    @get("/cookies/read", func {
        $bolt.json([:session_id = $bolt.cookie("session_id"), :prefs = $bolt.cookie("prefs")])
    })

    @get("/cookies/delete", func {
        $bolt.deleteCookie("session_id")
        $bolt.json([:deleted = "session_id"])
    })

    setCookieSecret("test-secret-key-32chars!")

    @get("/cookies/signed/set", func {
        $bolt.setSignedCookie("user", "alice")
        $bolt.json([:signed = true])
    })

    @get("/cookies/signed/read", func {
        user = $bolt.getSignedCookie("user")
        $bolt.json([:user = user])
    })

    @get("/session/set", func {
        $bolt.setSession("user_id", "42")
        $bolt.setSession("role", "admin")
        $bolt.json([:session_set = true])
    })

    @get("/session/read", func {
        $bolt.json([:user_id = $bolt.getSession("user_id"), :role = $bolt.getSession("role")])
    })

    @get("/session/delete", func {
        $bolt.deleteSession("role")
        $bolt.json([:session_deleted = "role"])
    })

    @get("/session/clear", func {
        $bolt.clearSession()
        $bolt.json([:session_cleared = true])
    })

    @get("/session/regenerate", func {
        $bolt.setSession("data", "before-regen")
        oldId = $bolt.cookie("BOLTSESSION")
        $bolt.regenerateSession()
        data = $bolt.getSession("data")
        $bolt.json([:old_id = oldId, :data_migrated = data, :regenerated = 1])
    })

    @get("/flash/set", func {
        $bolt.setFlash("message", "Operation completed!")
        $bolt.redirect("/flash/read")
    })

    @get("/flash/read", func {
        has = $bolt.hasFlash("message")
        msg = $bolt.getFlash("message")
        $bolt.json([:has_flash = has, :message = msg])
    })

    @get("/flash/read-again", func {
        has = $bolt.hasFlash("message")
        msg = $bolt.getFlash("message")
        $bolt.json([:has_flash = has, :message = msg])
    })
}
