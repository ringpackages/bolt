load "bolt.ring"

SECRET = "jwt-test-secret-that-is-at-least-32-chars"

csrfProtected = [:auto_protected = 1]

new Bolt() {
    cPort = sysget("BOLT_TEST_PORT")
    if cPort = "" { cPort = "3000" }
    port = number(cPort)

    @get("/health", func {
        $bolt.json([:status = "ok"])
    })

    @post("/jwt/login", func {
        data = $bolt.jsonBody()
        token = $bolt.jwtEncodeExp([:username = data[:username]], SECRET, 3600)
        $bolt.json([:token = token, :expires_in = 3600])
    })

    @post("/jwt/login-no-exp", func {
        data = $bolt.jsonBody()
        token = $bolt.jwtEncode([:username = data[:username]], SECRET)
        $bolt.json([:token = token])
    })

    @get("/jwt/me", func {
        auth = $bolt.header("Authorization")
        if isNull(auth) or auth = "" {
            $bolt.unauthorized()
            return
        }
        token = substr(auth, 8, len(auth) - 7)
        if $bolt.jwtVerify(token, SECRET) != 1 {
            $bolt.unauthorized()
            return
        ok
        payload = $bolt.jwtDecode(token, SECRET)
        if isNull(payload) {
            $bolt.unauthorized()
            return
        }
        $bolt.json([:user = payload])
    })

    @get("/basic-auth", func {
        auth = $bolt.header("Authorization")
        if auth = "" {
            $bolt.setHeader("WWW-Authenticate", 'Basic realm="Bolt"')
            $bolt.unauthorized()
            return
        }
        creds = $bolt.basicAuthDecode(auth)
        if isNull(creds) {
            $bolt.unauthorized()
            return
        }
        $bolt.json([:username = creds[:username], :password = creds[:password]])
    })

    @get("/basic-auth-encode", func {
        encoded = $bolt.basicAuthEncode("admin", "secret")
        decoded = $bolt.basicAuthDecode(encoded)
        $bolt.json([:encoded = encoded, :decoded = decoded])
    })

    enableCsrf("csrf-test-secret")

    @get("/csrf/token", func {
        $bolt.json([:csrf_token = $bolt.csrfToken()])
    })

    @post("/csrf/verify", func {
        submitted = $bolt.formField("_csrf")
        if $bolt.verifyCsrf(submitted) {
            $bolt.json([:valid = 1])
        else
            $bolt.forbidden()
        }
    })

    @post("/csrf/auto-protected", func {
        $bolt.json([:success = 1])
    })

    @post("/csrf/auto-protected-no-token", func {
        $bolt.json([:success = 1])
    })
}
