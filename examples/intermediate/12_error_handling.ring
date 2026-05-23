# Error Handling & Custom Error Pages
# Run: ring 12_error_handling.ring

load "bolt.ring"

new Bolt() {
    port = 3000

    # Home page
    @get("/", func {
        $bolt.html("
<h1>Error Handling Example</h1>
<h3>Try these:</h3>
<ul>
    <li><a href='/users/999'>404 - Not Found</a></li>
    <li><a href='/bad-request'>400 - Bad Request</a></li>
    <li><a href='/unauthorized'>401 - Unauthorized</a></li>
    <li><a href='/forbidden'>403 - Forbidden</a></li>
    <li><a href='/error'>500 - Server Error</a></li>
    <li><a href='/custom-error/418'>Custom Status Code</a></li>
</ul>
        ")
    })

    # 404 - Not Found
    @get("/users/:id", func {
        cId = $bolt.param("id")
        nId = 0 + cId

        if nId = 1
            $bolt.json([
                :id = 1,
                :name = "Alice"
            ])
        else
            $bolt.htmlWithStatus(404, "
<h1>404 - User Not Found</h1>
<p>User with ID " + cId + " does not exist</p>
<p><a href='/'>Go Home</a></p>
            ")
        ok
    })

    # 400 - Bad Request
    @get("/bad-request", func {
        $bolt.jsonWithStatus(400, [
            :error = "Bad Request",
            :message = "Invalid parameters provided",
            :code = 400
        ])
    })

    # 401 - Unauthorized
    @get("/unauthorized", func {
        $bolt.setHeader("WWW-Authenticate", "Bearer")
        $bolt.jsonWithStatus(401, [
            :error = "Unauthorized",
            :message = "Authentication required",
            :code = 401
        ])
    })

    # 403 - Forbidden
    @get("/forbidden", func {
        $bolt.htmlWithStatus(403, "
<h1>403 - Forbidden</h1>
<p>You don't have permission to access this resource</p>
<p><a href='/'>Go Home</a></p>
        ")
    })

    # 500 - Server Error
    @get("/error", func {
        $bolt.htmlWithStatus(500, "
<h1>500 - Internal Server Error</h1>
<p>Something went wrong on our end</p>
<p>Please try again later</p>
<p><a href='/'>Go Home</a></p>
        ")
    })

    # Custom status code
    @get("/custom-error/:code", func {
        cCode = $bolt.param("code")
        nCode = 0 + cCode

        $bolt.jsonWithStatus(nCode, [
            :statusCode = nCode,
            :message = "Custom status code set",
            :timestamp = $bolt.unixtime()
        ])
    })

    # JSON error example
    @get("/api/error", func {
        $bolt.jsonWithStatus(500, [
            :success = false,
            :error = [
                :code = "INTERNAL_ERROR",
                :message = "Database connection failed",
                :timestamp = $bolt.unixtime()
            ]
        ])
    })
}
