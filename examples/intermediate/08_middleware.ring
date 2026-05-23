# Middleware - @before and @after hooks
# Run: ring 08_middleware.ring

load "bolt.ring"

new Bolt() {
    port = 3000
    
    # @before runs BEFORE all routes
    @before(func {
        ? "[BEFORE] " + $bolt.method() + " " + $bolt.path()
        ? "[BEFORE] Request ID: " + $bolt.requestId()
        ? "[BEFORE] User-Agent: " + $bolt.header("User-Agent")
        
        # Add custom header to all responses
        $bolt.setHeader("X-Powered-By", "Bolt Framework")
        $bolt.setHeader("X-Request-ID", $bolt.requestId())
    })
    
    # @after runs AFTER all routes
    @after(func {
        ? "[AFTER] Response sent for " + $bolt.path()
        ? "[AFTER] Request completed"
    })
    
    # Regular routes
    @get("/", func {
        $bolt.html("
<h1>Middleware Example</h1>
<p>Check the server console - you'll see @before and @after logs!</p>
<p>Also check response headers for X-Powered-By and X-Request-ID</p>
<p>Try: <a href='/api/users'>GET /api/users</a></p>
        ")
    })
    
    @get("/api/users", func {
        $bolt.json([
            [:id = 1, :name = "Alice"],
            [:id = 2, :name = "Bob"]
        ])
    })
    
    @post("/api/data", func {
        cBody = $bolt.body()
        
        $bolt.json([
            :message = "Data received",
            :data = cBody
        ])
    })
}
