load "bolt.ring"


new Bolt() {
    cPort = sysget("BOLT_TEST_PORT")
    if cPort = "" { cPort = "3000" }
    port = number(cPort)

    @get("/health", func {
        $bolt.json([:status = "ok"])
    })

    enableDocs()
    setDocsInfo("Test API", "1.0.0", "API for testing docs")

    @get("/api/users", func {
        $bolt.json([:users = []])
    })
    describe("Get all users")
    tag("Users")

    @get("/api/users/:id", func {
        $bolt.json([:id = $bolt.param("id")])
    })
    describe("Get user by ID")
    tag("Users")

    homepage()
}
