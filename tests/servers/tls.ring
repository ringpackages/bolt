load "bolt.ring"

testDir = sysget("BOLT_TEST_DIR")

new Bolt() {
    cPort = sysget("BOLT_TEST_PORT")
    if cPort = "" { cPort = "3000" }
    port = number(cPort)

    enableTls(testDir + "/certs/cert.pem", testDir + "/certs/key.pem")

    @get("/health", func {
        $bolt.json([:status = "ok", :tls = true])
    })

    @get("/data", func {
        $bolt.json([:message = "secure hello"])
    })

    @get("/headers", func {
        $bolt.setHeader("X-TLS", "yes")
        $bolt.json([:tls = true])
    })
}
