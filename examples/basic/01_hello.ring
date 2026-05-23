// Hello World - Simple HTTP Server
// Run: ring 01_hello.ring
// Test: curl http://localhost:3000/

load "bolt.ring"

new Bolt() {
	@get("/", func {
		$bolt.send("Hello from Bolt ⚡ 🚀")
	})
	
	@get("/json", func {
		# curl http://localhost:3000/json
		$bolt.json([
			:message = "Hello JSON!",
			:status = "ok"
		])
	})
	
	@get("/user/:id", func {
		# curl http://localhost:3000/user/42
		cUserId = $bolt.param("id")
		$bolt.json([
			:id = cUserId,
			:name = "User " + cUserId
		])
	})
	
	@post("/echo", func {
		# curl -X POST http://localhost:3000/echo -d "hello"
		cData = $bolt.body()
		$bolt.send("You sent: " + cData)
	})
}
