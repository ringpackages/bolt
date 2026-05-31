load "bolt.ring"

testDir = sysget("BOLT_TEST_DIR")
env = new Env()

new Bolt() {
    cPort = sysget("BOLT_TEST_PORT")
    if cPort = "" { cPort = "3000" }
    port = number(cPort)

    @get("/health", func {
        $bolt.json([:status = "ok"])
    })

    @get("/env/get-var", func {
        val = env.getVar("HOME")
        $bolt.json([:key = "HOME", :value = val])
    })

    @get("/env/load-file", func {
        env.loadFile(testDir + "/test.env")
        $bolt.json([:value = env.getOr("TEST_ENV_VAR", "(not found)")])
    })

    @post("/env/set", func {
        data = $bolt.jsonBody()
        sysset(data[:key], data[:value])
        $bolt.json([:set = 1])
    })

    @get("/env/key/:name", func {
        name = $bolt.param("name")
        value = env.getOr(name, "(not set)")
        $bolt.json([:key = name, :value = value])
    })

    @get("/env/load-env", func {
        env.loadEnv()
        $bolt.json([:home = env.getVar("HOME")])
    })
}
