load "bolt.ring"


new Bolt() {
    cPort = sysget("BOLT_TEST_PORT")
    if cPort = "" { cPort = "3000" }
    port = number(cPort)

    @get("/health", func {
        $bolt.json([:status = "ok"])
    })

    @get("/methods/get", func {
        $bolt.json([:method = "GET"])
    })

    @post("/methods/post", func {
        $bolt.json([:method = "POST", :body = $bolt.jsonBody()])
    })

    @put("/methods/put", func {
        $bolt.json([:method = "PUT", :body = $bolt.jsonBody()])
    })

    @patch("/methods/patch", func {
        $bolt.json([:method = "PATCH", :body = $bolt.jsonBody()])
    })

    @delete("/methods/delete", func {
        $bolt.json([:method = "DELETE"])
    })

    @head("/methods/head", func {
        $bolt.setHeader("X-Method", "HEAD")
        $bolt.sendStatus(200)
    })

    @options("/methods/options", func {
        $bolt.setHeader("Allow", "GET, POST, PUT, PATCH, DELETE, HEAD, OPTIONS")
        $bolt.sendStatus(204)
    })

    @route("CUSTOM", "/methods/custom", func {
        $bolt.json([:method = $bolt.method()])
    })
}
