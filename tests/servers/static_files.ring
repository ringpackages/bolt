load "bolt.ring"

testDir = sysget("BOLT_TEST_DIR")

new Bolt() {
    cPort = sysget("BOLT_TEST_PORT")
    if cPort = "" { cPort = "3000" }
    port = number(cPort)

    @get("/health", func {
        $bolt.json([:status = "ok"])
    })

    @static("/public", "tests/static_test")

    @get("/send-file", func {
        $bolt.sendFile("tests/static_test/hello.txt")
    })

    @get("/send-file-as", func {
        $bolt.sendFileAs("tests/static_test/hello.txt", "text/plain")
    })
}
