# Route Grouping - Prefix, describe, tag, whereAll
# Run: ring 14_route_grouping.ring

load "bolt.ring"

new Bolt() {
    port = 3000

    # API v1 routes grouped under /api/v1
    prefix("/api/v1")

        @get("/users", func {
            $bolt.json([
                :version = "v1",
                :users = [[:id = 1, :name = "Alice"], [:id = 2, :name = "Bob"]]
            ])
        })
        describe("List all users")
        tag("Users")

        @get("/users/:id", func {
            $bolt.json([
                :version = "v1",
                :id = $bolt.param("id"),
                :name = "User " + $bolt.param("id")
            ])
        })
        where("id", "[0-9]+")
        describe("Get user by ID")
        tag("Users")

        @post("/users", func {
            data = $bolt.jsonBody()
            $bolt.jsonWithStatus(201, [:version = "v1", :created = true, :user = data])
        })
        describe("Create a new user")
        tag("Users")

        @get("/posts/:year/:month", func {
            $bolt.json([
                :version = "v1",
                :year = $bolt.param("year"),
                :month = $bolt.param("month"),
                :posts = []
            ])
        })
        whereAll([
            ["year", "[0-9]{4}"],
            ["month", "(0[1-9]|1[0-2])"]
        ])
        describe("Get posts by year and month")
        tag("Posts")

    endPrefix()

    # API v2 routes grouped under /api/v2
    prefix("/api/v2")

        @get("/users", func {
            $bolt.json([
                :version = "v2",
                :users = [[:id = 1, :name = "Alice", :email = "alice@example.com"]]
            ])
        })
        describe("List all users (v2)")
        tag("Users")

    endPrefix()

    # Admin routes grouped under /admin
    prefix("/admin")

        @get("/dashboard", func {
            $bolt.send("Admin Dashboard")
        })

        @get("/users", func {
            $bolt.json([:admin = true, :users = []])
        })

    endPrefix()

    @get("/", func {
        $bolt.html(`
<h1>Route Grouping Example</h1>
<h3>Try these:</h3>
<pre>
# API v1 routes
curl http://localhost:3000/api/v1/users
curl http://localhost:3000/api/v1/users/42
curl -X POST http://localhost:3000/api/v1/users -H 'Content-Type: application/json' -d '{"name":"Charlie"}'
curl http://localhost:3000/api/v1/posts/2024/03

# whereAll constraints - valid
curl http://localhost:3000/api/v1/posts/2024/06

# whereAll constraints - invalid month (404)
curl http://localhost:3000/api/v1/posts/2024/15

# API v2 routes
curl http://localhost:3000/api/v2/users

# Admin routes
curl http://localhost:3000/admin/dashboard
curl http://localhost:3000/admin/users
</pre>
        `)
    })
}
