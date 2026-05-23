# Custom OpenAPI Spec - Override Auto-Generated Docs
# Run: ring 43_openapi_custom.ring
# Demonstrates: setOpenApiSpec, setDocsInfo, custom OpenAPI JSON

load "bolt.ring"

cSpec = '{
  "openapi": "3.0.0",
  "info": {
    "title": "Custom API Documentation",
    "version": "2.0.0",
    "description": "API with custom OpenAPI spec - overrides auto-generated docs"
  },
  "paths": {
    "/api/products": {
      "get": {
        "summary": "List all products",
        "operationId": "listProducts",
        "tags": ["products"],
        "responses": {
          "200": {
            "description": "Product list",
            "content": {
              "application/json": {
                "schema": {
                  "type": "array",
                  "items": { "$ref": "#/components/schemas/Product" }
                }
              }
            }
          }
        }
      },
      "post": {
        "summary": "Create a product",
        "operationId": "createProduct",
        "tags": ["products"],
        "requestBody": {
          "required": true,
          "content": {
            "application/json": {
              "schema": { "$ref": "#/components/schemas/ProductInput" }
            }
          }
        },
        "responses": {
          "201": { "description": "Product created" }
        }
      }
    },
    "/api/products/{id}": {
      "get": {
        "summary": "Get product by ID",
        "operationId": "getProduct",
        "tags": ["products"],
        "parameters": [
          { "name": "id", "in": "path", "required": true, "schema": { "type": "integer" } }
        ],
        "responses": {
          "200": { "description": "Product details" },
          "404": { "description": "Not found" }
        }
      }
    }
  },
  "components": {
    "schemas": {
      "Product": {
        "type": "object",
        "properties": {
          "id": { "type": "integer" },
          "name": { "type": "string" },
          "price": { "type": "number" }
        }
      },
      "ProductInput": {
        "type": "object",
        "required": ["name", "price"],
        "properties": {
          "name": { "type": "string" },
          "price": { "type": "number" }
        }
      }
    }
  }
}'

new Bolt() {
    port = 3000

    setDocsInfo("Custom API", "2.0.0", "API with custom OpenAPI spec")
    setOpenApiSpec(cSpec)

    @get("/health", func {
        $bolt.json([:status = "ok"])
    })

    @get("/", func {
        cSpec = `curl http://localhost:3000/openapi.json | jq .`
        cList = `curl http://localhost:3000/api/products`
        cCreate = `curl -X POST http://localhost:3000/api/products \
  -H "Content-Type: application/json" \
  -d '{"name": "Doohickey", "price": 14.99}'`
        cGet = `curl http://localhost:3000/api/products/1
curl http://localhost:3000/api/products/999`

        $bolt.renderFile("./templates/layout.html", [
            :title = "Bolt - Custom OpenAPI Spec",
            :subtitle = "Override auto-generated docs with custom OpenAPI JSON",
            :sections = [
                [:title = "Endpoints", :items = [
                    "GET /openapi.json - Custom OpenAPI spec (not auto-generated)",
                    "GET /api/products - List products",
                    "POST /api/products - Create product",
                    "GET /api/products/:id - Get product by ID"
                ]],
                [:title = "How it works", :code = `setOpenApiSpec(cJson) -> Overrides auto-generated OpenAPI spec
setDocsInfo(t, v, d)  -> Sets API title, version, description

The /openapi.json endpoint now returns the custom spec
instead of the auto-generated one from routes.`],
                [:title = "Test with curl", :subsections = [
                    [:title = "View custom OpenAPI spec", :code = cSpec],
                    [:title = "List products", :code = cList],
                    [:title = "Create a product", :code = cCreate],
                    [:title = "Get product by ID", :code = cGet]
                ]]
            ]
        ])
    })

    aProducts = [
        [:id = 1, :name = "Widget", :price = 9.99],
        [:id = 2, :name = "Gadget", :price = 24.99]
    ]

    @get("/api/products", func {
        $bolt.json(aProducts)
    })

    @post("/api/products", func {
        data = $bolt.jsonBody()
        nId = len(aProducts) + 1
        aProducts + [:id = nId, :name = data[:name], :price = 0 + data[:price]]
        $bolt.jsonWithStatus(201, aProducts[nId])
    })

    @get("/api/products/:id", func {
        nId = 0 + $bolt.param("id")
        if nId >= 1 and nId <= len(aProducts) {
            $bolt.json(aProducts[nId])
        else
            $bolt.notFound()
        ok
    })
}