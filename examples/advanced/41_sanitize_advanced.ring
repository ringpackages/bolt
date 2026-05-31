# Advanced Sanitization - Attribute, JS, URL Escaping
# Run: ring 41_sanitize_advanced.ring
# Demonstrates: escapeAttr, escapeJs, escapeUrl

load "bolt.ring"

s = new Sanitize

new Bolt() {
    port = 3000

    @get("/health", func {
        $bolt.json([:status = "ok"])
    })

    @get("/", func {
        $bolt.renderFile("./templates/layout.html", [
            :title = "Bolt - Advanced Sanitization",
            :subtitle = "Attribute, JS, URL escaping",
            :sections = [
                [:title = "Test with curl", :subsections = [
                    [:title = "Health check", :code = "curl http://localhost:3000/health"],
                    [:title = "Escape HTML attribute", :code = "curl -X POST http://localhost:3000/escape/attr -H 'Content-Type: application/json' -d " + '{"input": "test onclick alert(1)"}'],
                    [:title = "Escape JavaScript", :code = "curl -X POST http://localhost:3000/escape/js -H 'Content-Type: application/json' -d " + '{"input": "hello script alert(1) /script"}'],
                    [:title = "Escape URL", :code = "curl -X POST http://localhost:3000/escape/url -H 'Content-Type: application/json' -d " + '{"input": "https://example.com/?q=hello&lang=en"}'],
                    [:title = "All methods compared", :code = "curl -X POST http://localhost:3000/escape/all -H 'Content-Type: application/json' -d " + '{"input": "script alert(xss) /script"}'],
                    [:title = "Built-in demo", :code = "curl http://localhost:3000/escape/demo"]
                ]],
                [:title = "Endpoints", :items = [
                    "POST /escape/attr - escapeAttr() - Safe HTML attribute values",
                    "POST /escape/js - escapeJs() - Safe JavaScript string literals",
                    "POST /escape/url - escapeUrl() - Safe URL components",
                    "POST /escape/all - All escaping methods compared",
                    "GET /escape/demo - Demonstrates each method"
                ]],
                [:title = "Sanitize Class Methods", :code = `s.html(cInput)       -> Strip dangerous HTML, keep safe tags
s.strict(cInput)     -> Strip ALL HTML tags
s.escapeHtml(cInput) -> Escape HTML entities
s.escapeAttr(cInput) -> Escape for HTML attribute values
s.escapeJs(cInput)   -> Escape for JavaScript string literals
s.escapeUrl(cInput)  -> URL-encode for safe URL components`]
            ]
        ])
    })

    @post("/escape/attr", func {
        data = $bolt.jsonBody()
        cInput = data[:input]
        cEscaped = s.escapeAttr(cInput)
        $bolt.json([
            :input = cInput,
            :escaped = cEscaped,
            :method = "escapeAttr",
            :useCase = "Safe for HTML attribute values like class='...'"
        ])
    })

    @post("/escape/js", func {
        data = $bolt.jsonBody()
        cInput = data[:input]
        cEscaped = s.escapeJs(cInput)
        $bolt.json([
            :input = cInput,
            :escaped = cEscaped,
            :method = "escapeJs",
            :useCase = "Safe for JavaScript string literals like var x = '...'"
        ])
    })

    @post("/escape/url", func {
        data = $bolt.jsonBody()
        cInput = data[:input]
        cEscaped = s.escapeUrl(cInput)
        $bolt.json([
            :input = cInput,
            :escaped = cEscaped,
            :method = "escapeUrl",
            :useCase = "Safe for URL query parameters like ?q=..."
        ])
    })

    @post("/escape/all", func {
        data = $bolt.jsonBody()
        cInput = data[:input]
        $bolt.json([
            :input = cInput,
            :escapeHtml = s.escapeHtml(cInput),
            :escapeAttr = s.escapeAttr(cInput),
            :escapeJs = s.escapeJs(cInput),
            :escapeUrl = s.escapeUrl(cInput),
            :sanitizeHtml = s.html(cInput),
            :sanitizeStrict = s.strict(cInput)
        ])
    })

    @get("/escape/demo", func {
        cDemo = '<script>alert("xss")</script><p class="test">Hello & World</p>'
        $bolt.json([
            :input = cDemo,
            :escapeHtml = s.escapeHtml(cDemo),
            :escapeAttr = s.escapeAttr(cDemo),
            :escapeJs = s.escapeJs(cDemo),
            :escapeUrl = s.escapeUrl(cDemo)
        ])
    })
}