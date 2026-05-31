load "bolt.ring"


new Bolt() {
    cPort = sysget("BOLT_TEST_PORT")
    if cPort = "" { cPort = "3000" }
    port = number(cPort)

    @get("/health", func {
        $bolt.json([:status = "ok"])
    })

    @get("/params/:id", func {
        $bolt.json([:id = $bolt.param("id")])
    })

    @get("/params/:id/posts/:postId", func {
        $bolt.json([:id = $bolt.param("id"), :postId = $bolt.param("postId")])
    })

    @get("/items/:id", func {
        $bolt.json([:id = $bolt.param("id")])
    })
    where("id", "[0-9]+")

    @get("/slugs/:slug", func {
        $bolt.json([:slug = $bolt.param("slug")])
    })
    where("slug", "[a-z0-9-]+")

    @get("/archive/:year/:month", func {
        $bolt.json([:year = $bolt.param("year"), :month = $bolt.param("month")])
    })
    whereAll([
        ["year", "[0-9]{4}"],
        ["month", "(0[1-9]|1[0-2])"]
    ])

    @get("/products/:category/:sku", func {
        $bolt.json([:category = $bolt.param("category"), :sku = $bolt.param("sku")])
    })
    whereAll([
        ["category", "[a-z]+"],
        ["sku", "[A-Z]{2}-[0-9]{4}"]
    ])

    prefix("/api/v1")
        @get("/status", func {
            $bolt.json([:version = "v1", :status = "ok"])
        })
    endPrefix()

    prefix("/api/v2")
        @get("/status", func {
            $bolt.json([:version = "v2", :status = "ok"])
        })
    endPrefix()

    @get("/search", func {
        $bolt.json([:q = $bolt.query("q"), :page = $bolt.query("page")])
    })

    @get("/multi-query", func {
        $bolt.json([:tags = $bolt.queryAll("tag")])
    })
}
