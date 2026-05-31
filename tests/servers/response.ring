load "bolt.ring"

testDir = sysget("BOLT_TEST_DIR")

new Bolt() {
    cPort = sysget("BOLT_TEST_PORT")
    if cPort = "" { cPort = "3000" }
    port = number(cPort)

    @get("/health", func {
        $bolt.json([:status = "ok"])
    })

    @get("/text", func {
        $bolt.send("Hello from Bolt!")
    })

    @get("/status-only", func {
        $bolt.sendStatus(204)
    })

    @get("/custom-status", func {
        $bolt.sendWithStatus(418, "I'm a teapot")
    })

    @get("/json-200", func {
        $bolt.json([:ok = 1])
    })

    @get("/json-201", func {
        $bolt.jsonWithStatus(201, [:created = 1, :id = $bolt.uuid()])
    })

    @get("/redirect-temp", func {
        $bolt.redirect("/text")
    })

    @get("/redirect-perm", func {
        $bolt.redirectPermanent("/text")
    })

    @get("/not-found", func {
        $bolt.notFound()
    })

    @get("/bad-request", func {
        $bolt.badRequest("Missing fields")
    })

    @get("/unauthorized", func {
        $bolt.unauthorized()
    })

    @get("/forbidden", func {
        $bolt.forbidden()
    })

    @get("/server-error", func {
        $bolt.serverError("DB failed")
    })

    @get("/custom-header", func {
        $bolt.setHeader("X-Custom", "bolt-value")
        $bolt.setHeader("Cache-Control", "no-cache")
        $bolt.json([:headers = "set"])
    })

    @get("/etag", func {
        content = $bolt.jsonEncode([:data = "cached"])
        etagVal = $bolt.etag(content)
        $bolt.setHeader("ETag", etagVal)
        $bolt.send(content)
    })

    @post("/echo-body", func {
        $bolt.json([:received = $bolt.body()])
    })

    @get("/send-file", func {
        $bolt.sendFile("tests/static_test/hello.txt")
    })

    @get("/send-file-as", func {
        $bolt.sendFileAs("tests/static_test/hello.txt", "text/plain")
    })

    @get("/send-binary", func {
        data = $bolt.base64Encode("binary content here")
        $bolt.sendBinary(data)
    })

    @get("/send-binary-as", func {
        data = $bolt.base64Encode("PDF content here")
        $bolt.sendBinaryAs(data, "application/pdf")
    })

    @get("/html-status", func {
        $bolt.htmlWithStatus(201, "<h1>Created</h1>")
    })
}
