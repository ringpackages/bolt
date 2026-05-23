# Error Responses - Status Codes, Custom Errors, Redirects
# Run: ring 38_error_responses.ring
# Demonstrates: sendStatus, sendWithStatus, serverError, jsonWithStatus, sendBinaryAs, sendFileAs, redirectPermanent

load "bolt.ring"

new Bolt() {
    port = 3000

    @error(func {
        cPath = $bolt.path()
        cMethod = $bolt.method()
        $bolt.jsonWithStatus(500, [
            :error = "Internal Server Error",
            :path = cPath,
            :method = cMethod,
            :requestId = $bolt.requestId()
        ])
    })

    @get("/health", func {
        $bolt.json([:status = "ok"])
    })

    @get("/", func {
        cStatus = `curl -i http://localhost:3000/status/204
curl -i http://localhost:3000/status/418`
        cErrors = `curl http://localhost:3000/server-error
curl http://localhost:3000/not-implemented
curl http://localhost:3000/rate-limited
curl http://localhost:3000/conflict
curl http://localhost:3000/cause-error`
        cRedirect = `curl -i http://localhost:3000/redirect-perm`
        cBinary = `curl http://localhost:3000/binary-custom
curl http://localhost:3000/file-custom`

        $bolt.renderFile("./templates/layout.html", [
            :title = "Bolt - Error Responses",
            :subtitle = "Status codes, custom errors, redirects",
            :sections = [
                [:title = "Test Endpoints", :items = [
                    "GET /status/204 - sendStatus(204) No Content",
                    "GET /status/418 - sendWithStatus(418, I'm a teapot)",
                    "GET /server-error - serverError(Something went wrong)",
                    "GET /not-implemented - jsonWithStatus(501, {...})",
                    "GET /rate-limited - jsonWithStatus(429, {...})",
                    "GET /conflict - jsonWithStatus(409, {...})",
                    "GET /cause-error - Triggers the custom @error handler",
                    "GET /redirect-perm - redirectPermanent(/moved-target)",
                    "GET /moved-target - Target for permanent redirect",
                    "GET /binary-custom - sendBinaryAs() with custom content type",
                    "GET /file-custom - sendFileAs() with custom content type"
                ]],
                [:title = "Test with curl", :subsections = [
                    [:title = "Send specific status code", :code = cStatus],
                    [:title = "Error responses", :code = cErrors],
                    [:title = "Redirect", :code = cRedirect],
                    [:title = "Binary and file responses", :code = cBinary]
                ]]
            ]
        ])
    })

    @get("/status/:code", func {
        cCode = $bolt.param("code")
        nCode = 0 + cCode
        $bolt.sendStatus(nCode)
    })

    @get("/server-error", func {
        $bolt.serverError("Database connection lost")
    })

    @get("/not-implemented", func {
        $bolt.jsonWithStatus(501, [
            :error = "Not Implemented",
            :message = "This endpoint is not yet available"
        ])
    })

    @get("/rate-limited", func {
        $bolt.jsonWithStatus(429, [
            :error = "Too Many Requests",
            :retryAfter = 60
        ])
    })

    @get("/conflict", func {
        $bolt.jsonWithStatus(409, [
            :error = "Conflict",
            :message = "Resource already exists"
        ])
    })

    @get("/cause-error", func {
        raise("intentional error for testing")
    })

    @get("/redirect-perm", func {
        $bolt.redirectPermanent("/moved-target")
    })

    @get("/moved-target", func {
        $bolt.json([:message = "You were permanently redirected here", :status = 301])
    })

    @get("/binary-custom", func {
        $bolt.sendBinaryAs("SGVsbG8gZnJvbSBzZW5kQmluYXJ5QXM=", "text/plain")
    })

    @get("/file-custom", func {
        $bolt.sendFileAs("_demo_readme.txt", "text/plain")
    })
}