# Advanced Response Methods - Files, binary, redirects, custom methods
# Run: ring 32_advanced_response.ring

load "bolt.ring"

cDir = currentdir()

# Create temp files for sendFile demo
write(cDir + "/_demo_readme.txt", "Bolt Framework - Advanced Response Demo\nThis file was created by 32_advanced_response.ring")
write(cDir + "/_demo_data.bin", "Binary demo data from Bolt")

new Bolt() {
    port = 3000

    # Send a file with auto-detected MIME type
    # curl -i http://localhost:3000/download/readme
    @get("/download/readme", func {
        $bolt.sendFile("_demo_readme.txt")
    })

    # Send a file with explicit MIME type
    # curl -i http://localhost:3000/download/data
    @get("/download/data", func {
        $bolt.sendFileAs("_demo_data.bin", "application/octet-stream")
    })

    # Send binary data (base64-encoded)
    # curl -i http://localhost:3000/binary
    @get("/binary", func {
        cBase64 = "SGVsbG8gZnJvbSBCb2x0IEJpbmFyeSE="
        $bolt.sendBinary(cBase64)
    })

    # Send binary with custom MIME type
    # curl -i http://localhost:3000/binary/png
    @get("/binary/png", func {
        cBase64 = "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg=="
        $bolt.sendBinaryAs(cBase64, "image/png")
    })

    # Temporary redirect (302)
    # curl -i http://localhost:3000/old-page
    @get("/old-page", func {
        $bolt.redirect("/new-page")
    })

    # Permanent redirect (301)
    # curl -i http://localhost:3000/legacy
    @get("/legacy", func {
        $bolt.redirectPermanent("/new-page")
    })

    @get("/new-page", func {
        $bolt.json([:message = "You've been redirected!", :page = "new-page"])
    })

    # HEAD method - headers only, no body
    # curl -I http://localhost:3000/health
    @head("/health", func {
        $bolt.setHeader("X-Status", "healthy")
        $bolt.setHeader("X-Server", "Bolt")
        $bolt.sendStatus(200)
    })

    # OPTIONS method - CORS preflight
    # curl -X OPTIONS -i http://localhost:3000/api/data
    @options("/api/data", func {
        $bolt.setHeader("Allow", "GET, POST, PUT, DELETE, OPTIONS")
        $bolt.setHeader("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS")
        $bolt.setHeader("Access-Control-Allow-Headers", "Content-Type, Authorization")
        $bolt.sendStatus(204)
    })

    # Custom HTTP method
    # curl -X REPORT http://localhost:3000/report
    @route("REPORT", "/report", func {
        $bolt.json([:method = "REPORT", :message = "Custom method handler"])
    })

    # JSON encode/decode/pretty utilities
    @get("/json-utils", func {
        aData = [:name = "Alice", :items = [1, 2, 3]]
        $bolt.json([
            :encoded = $bolt.jsonEncode(aData),
            :pretty = $bolt.jsonPretty(aData),
            :decoded = $bolt.jsonDecode('{"key":"value","num":42}'),
            :etag = $bolt.etag("some content here")
        ])
    })

    # renderTemplate - render without sending
    @get("/render-template", func {
        cHtml = $bolt.renderTemplate("<h1>Hello, {{ name }}!</h1><p>Time: {{ time }}</p>", [
            :name = "Bolt User",
            :time = $bolt.unixtime()
        ])
        $bolt.html(cHtml)
    })

    @get("/", func {
        $bolt.renderFile("./templates/layout.html", [
            :title = "Bolt - Advanced Response Methods",
            :subtitle = "Files, binary, redirects, custom methods",
            :sections = [
                [:title = "Endpoints", :subsections = [
                    [:title = "Send file", :code = "curl -i http://localhost:3000/download/readme
curl -i http://localhost:3000/download/data"],
                    [:title = "Binary responses", :code = "curl -i http://localhost:3000/binary
curl -i http://localhost:3000/binary/png"],
                    [:title = "Redirects (302 and 301)", :code = "curl -i http://localhost:3000/old-page
curl -i http://localhost:3000/legacy"],
                    [:title = "Redirect target", :code = "curl http://localhost:3000/new-page"],
                    [:title = "HEAD (headers only)", :code = "curl -I http://localhost:3000/health"],
                    [:title = "OPTIONS (CORS preflight)", :code = "curl -X OPTIONS -i http://localhost:3000/api/data"],
                    [:title = "Custom HTTP method", :code = "curl -X REPORT http://localhost:3000/report"],
                    [:title = "JSON utilities", :code = "curl http://localhost:3000/json-utils"],
                    [:title = "renderTemplate (render without auto-send)", :code = "curl http://localhost:3000/render-template"]
                ]]
            ]
        ])
    })
}
