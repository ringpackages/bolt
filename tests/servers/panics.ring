load "bolt.ring"

new Bolt() {
    cPort = sysget("BOLT_TEST_PORT")
    if cPort = "" { cPort = "3000" }
    port = number(cPort)

    @get("/health", func {
        $bolt.json([:status = "ok"])
    })

    @get("/panic", func {
        raise("intentional panic for testing")
    })

    @get("/divide-zero", func {
        x = 1 / 0
        $bolt.json([:result = x])
    })

    @get("/nil-access", func {
        aList = []
        val = aList[999]
        $bolt.json([:val = val])
    })

    @get("/safe", func {
        $bolt.json([:ok = 1])
    })

    @error(func {
        $bolt.jsonWithStatus(500, [:error = 1, :caught = 1])
    })
}
