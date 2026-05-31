load "bolt.ring"

SECRET = "jwt-edge-case-secret-at-least-32-bytes!"

new Bolt() {
    cPort = sysget("BOLT_TEST_PORT")
    if cPort = "" { cPort = "3000" }
    port = number(cPort)

    @get("/health", func {
        $bolt.json([:status = "ok"])
    })

    enableCsrf("csrf-edge-secret")

    @get("/csrf/token", func {
        $bolt.json([:csrf_token = $bolt.csrfToken()])
    })

    @post("/csrf/header-token", func {
        submitted = $bolt.header("X-CSRF-Token")
        if $bolt.verifyCsrf(submitted) {
            $bolt.json([:valid = 1])
        else
            $bolt.forbidden()
        }
    })

    @post("/csrf/query-token", func {
        submitted = $bolt.query("_csrf")
        if $bolt.verifyCsrf(submitted) {
            $bolt.json([:valid = 1])
        else
            $bolt.forbidden()
        }
    })

    @post("/jwt/login", func {
        data = $bolt.jsonBody()
        token = $bolt.jwtEncodeExp([:username = data[:username]], SECRET, 3600)
        $bolt.json([:token = token])
    })

    @post("/jwt/login-short-secret", func {
        data = $bolt.jsonBody()
        token = $bolt.jwtEncodeExp([:username = data[:username]], "short", 3600)
        $bolt.json([:token = token])
    })

    @post("/jwt/login-expired", func {
        data = $bolt.jsonBody()
        token = $bolt.jwtEncodeExp([:username = data[:username]], SECRET, -1)
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

    @post("/csrf/auto-protected", func {
        $bolt.json([:success = 1])
    })

    csrfAutoVerify()
}
