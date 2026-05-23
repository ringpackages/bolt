# JSON Schema Validation & Regex Validation
# Run: ring 29_json_schema.ring

load "bolt.ring"

new Bolt() {
    port = 3000

    # User creation with JSON Schema validation
    cUserSchema = '{
        "type": "object",
        "properties": {
            "name": {"type": "string", "minLength": 1, "maxLength": 100},
            "email": {"type": "string", "format": "email"},
            "age": {"type": "integer", "minimum": 0, "maximum": 150}
        },
        "required": ["name", "email"]
    }'

    @post("/users", func {
        cBody = $bolt.body()

        if !$bolt.validateJson(cBody, cUserSchema)
            aErrors = $bolt.validateJsonErrors(cBody, cUserSchema)
            $bolt.jsonWithStatus(400, [
                :error = "Validation failed",
                :details = aErrors
            ])
            return
        ok

        data = $bolt.jsonBody()
        $bolt.jsonWithStatus(201, [
            :created = true,
            :user = data
        ])
    })

    # Product with complex schema
    cProductSchema = '{
        "type": "object",
        "properties": {
            "name": {"type": "string", "minLength": 1},
            "price": {"type": "number", "minimum": 0},
            "tags": {"type": "array", "items": {"type": "string"}},
            "in_stock": {"type": "boolean"}
        },
        "required": ["name", "price"]
    }'

    @post("/products", func {
        cBody = $bolt.body()

        if !$bolt.validateJson(cBody, cProductSchema)
            aErrors = $bolt.validateJsonErrors(cBody, cProductSchema)
            $bolt.jsonWithStatus(400, [
                :error = "Validation failed",
                :details = aErrors
            ])
            return
        ok

        data = $bolt.jsonBody()
        $bolt.jsonWithStatus(201, [:created = true, :product = data])
    })

    # Validate URL parameter against regex
    @get("/validate/:id", func {
        if !$bolt.validateParam("id", "^[0-9]+$")
            $bolt.badRequest("ID must be numeric")
            return
        ok
        $bolt.json([:id = $bolt.param("id"), :valid = true])
    })

    # Match regex pattern
    @post("/match", func {
        data = $bolt.jsonBody()

        $bolt.json([
            :email_valid = $bolt.matchRegex(data[:email], "^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+[.][a-zA-Z]{2,}$"),
            :phone_valid = $bolt.matchRegex(data[:phone], "^[0-9]{10,15}$"),
            :slug_valid = $bolt.matchRegex(data[:slug], "^[a-z0-9-]+$")
        ])
    })

    @get("/", func {
        cValidUser = `curl -X POST http://localhost:3000/users -H 'Content-Type: application/json' -d '{"name":"Alice","email":"alice@example.com","age":25}'`
        cInvalidUser = `curl -X POST http://localhost:3000/users -H 'Content-Type: application/json' -d '{"age":-5}'`
        cValidProduct = `curl -X POST http://localhost:3000/products -H 'Content-Type: application/json' -d '{"name":"Widget","price":9.99,"tags":["tool"],"in_stock":true}'`
        cInvalidProduct = `curl -X POST http://localhost:3000/products -H 'Content-Type: application/json' -d '{"name":"Widget","price":-5}'`
        cValidate = `curl http://localhost:3000/validate/123
curl http://localhost:3000/validate/abc`
        cMatch = `curl -X POST http://localhost:3000/match -H 'Content-Type: application/json' -d '{"email":"test@example.com","phone":"1234567890","slug":"my-post"}'`

        $bolt.renderFile("./templates/layout.html", [
            :title = "Bolt - JSON Schema & Regex",
            :subtitle = "JSON Schema validation and regex pattern matching",
            :sections = [
                [:title = "Endpoints", :items = [
                    "POST /users - Create user with JSON Schema validation",
                    "POST /products - Create product with complex schema",
                    "GET /validate/:id - Validate URL parameter against regex",
                    "POST /match - Match regex patterns (email, phone, slug)"
                ]],
                [:title = "Test with curl", :subsections = [
                    [:title = "Valid user", :code = cValidUser],
                    [:title = "Invalid user (missing required fields)", :code = cInvalidUser],
                    [:title = "Valid product", :code = cValidProduct],
                    [:title = "Invalid product (negative price)", :code = cInvalidProduct],
                    [:title = "Validate param (numeric ID)", :code = cValidate],
                    [:title = "Regex matching", :code = cMatch]
                ]]
            ]
        ])
    })
}
