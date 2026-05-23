# Request Context - queryAll, bodyBase64, uri
# Run: ring 37_request_context.ring
# Demonstrates: queryAll, bodyBase64, uri, formField, formFieldAll

load "bolt.ring"

new Bolt() {
    port = 3000

    @get("/health", func {
        $bolt.json([:status = "ok"])
    })

    @get("/", func {
        cQuery = `curl "http://localhost:3000/query-all?tag=rust&tag=web&tag=fast&sort=newest"`
        cBody = `curl -X POST http://localhost:3000/body-base64 \
  -H "Content-Type: application/octet-stream" \
  -d 'binary data here'`
        cUri = `curl "http://localhost:3000/uri-info?q=search+term"`
        cForm = `curl -X POST http://localhost:3000/form-fields \
  -F "name=Alice" \
  -F "hobby=reading" \
  -F "hobby=coding"`
        cDetails = `curl -H "User-Agent: test-client" http://localhost:3000/request-details`

        $bolt.renderFile("./templates/layout.html", [
            :title = "Bolt - Request Context",
            :subtitle = "queryAll, bodyBase64, uri, formField, formFieldAll",
            :sections = [
                [:title = "Endpoints", :items = [
                    "GET /query-all?tag=rust&tag=web&tag=fast - queryAll() multi-value params",
                    "POST /body-base64 - bodyBase64() binary-safe body",
                    "GET /uri-info - uri() raw URI with query string",
                    "POST /form-fields - formField(), formFieldAll()",
                    "GET /request-details - Full request context"
                ]],
                [:title = "Test with curl", :subsections = [
                    [:title = "Multi-value query params", :code = cQuery],
                    [:title = "Binary-safe body (base64)", :code = cBody],
                    [:title = "URI info", :code = cUri],
                    [:title = "Form fields (multipart)", :code = cForm],
                    [:title = "Full request details", :code = cDetails]
                ]]
            ]
        ])
    })

    @get("/query-all", func {
        aTags = $bolt.queryAll("tag")
        cSort = $bolt.query("sort")
        $bolt.json([
            :tags = aTags,
            :sort = cSort,
            :count = len(aTags),
            :uri = $bolt.uri()
        ])
    })

    @post("/body-base64", func {
        cRaw = $bolt.body()
        cB64 = $bolt.bodyBase64()
        $bolt.json([
            :raw = cRaw,
            :base64 = cB64,
            :length = len(cRaw),
            :note = "bodyBase64() is binary-safe, body() is lossy UTF-8"
        ])
    })

    @get("/uri-info", func {
        $bolt.json([
            :uri = $bolt.uri(),
            :path = $bolt.path(),
            :method = $bolt.method(),
            :query = $bolt.query("q"),
            :allParams = $bolt.uri()
        ])
    })

    @post("/form-fields", func {
        cName = $bolt.formField("name")
        aHobbies = $bolt.formFieldAll("hobby")
        $bolt.json([
            :name = cName,
            :hobbies = aHobbies,
            :hobbyCount = len(aHobbies)
        ])
    })

    @get("/request-details", func {
        $bolt.json([
            :method = $bolt.method(),
            :path = $bolt.path(),
            :uri = $bolt.uri(),
            :clientIp = $bolt.clientIp(),
            :requestId = $bolt.requestId(),
            :userAgent = $bolt.header("User-Agent"),
            :contentType = $bolt.header("Content-Type")
        ])
    })
}