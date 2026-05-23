# Templates - MiniJinja Rendering (Inline + File-Based)
# Run: ring 10_templates.ring
# Open: http://localhost:3000
#
# This example demonstrates two ways to use MiniJinja templates:
#   1. render()     - Inline template strings in Ring code
#   2. renderFile() - External .html template files with inheritance
#
# Template files are in the ./templates/ directory:
#   base.html    - Base layout with nav, footer, and blocks
#   home.html    - Extends base, shows features grid + stats
#   about.html   - Extends base, shows timeline + values
#   team.html    - Extends base, shows team member cards
#   contact.html - Extends base, shows contact form + info

load "bolt.ring"

aFeatures = [
    [:icon = "⚡", :title = "Fast", :desc = "Built on a Rust backend for maximum performance"],
    [:icon = "🧩", :title = "Modular", :desc = "Use only what you need, extend as you grow"],
    [:icon = "🎨", :title = "Templates", :desc = "MiniJinja-powered templating with inheritance"],
    [:icon = "🔒", :title = "Secure", :desc = "Built-in CSRF, CORS, and session management"],
    [:icon = "📡", :title = "Real-time", :desc = "WebSocket and SSE support out of the box"],
    [:icon = "📦", :title = "Lightweight", :desc = "Minimal dependencies, small footprint"]
]

aStats = [
    [:label = "Requests/sec", :value = "300,000+"],
    [:label = "Dependencies", :value = "0"],
    [:label = "Uptime", :value = "99.9%"]
]

aTimeline = [
    [:year = "Month 1 — Week 1", :text = "Project inception — Actix-web + Ring FFI bridge, basic HTTP server with routing and request context"],
    [:year = "Month 1 — Week 2", :text = "Full response system — JSON, file, binary, redirects, status codes, static files, all 7 HTTP methods"],
    [:year = "Month 1 — Week 3", :text = "MiniJinja templates — inline render() + file-based renderFile() with template inheritance, middleware (before/after hooks, CORS, compression)"],
    [:year = "Month 1 — Week 4", :text = "Cookies, sessions, flash messages, file uploads with multipart streaming, ETag caching, signed cookies"],
    [:year = "Month 2 — Week 1", :text = "Real-time — WebSocket with rooms/broadcast/binary, SSE with named events, connection management"],
    [:year = "Month 2 — Week 2", :text = "Auth & security — JWT encoding/verification with expiry, Basic Auth, CSRF, rate limiting, IP whitelist/blacklist"],
    [:year = "Month 2 — Week 3", :text = "Production hardening — TLS via rustls, OpenAPI/Swagger docs, logging levels, health checks, graceful shutdown"],
    [:year = "Month 2 — Week 4", :text = "Utility layer — Argon2/Bcrypt/Scrypt hashing, AES-256-GCM, HMAC, JSON Schema validation, XSS sanitization, .env loader, regex/match utilities"]
]

aValues = [
    [:name = "Simplicity", :desc = "Easy to learn, easy to use. Code should read like English."],
    [:name = "Performance", :desc = "Speed matters. Every millisecond counts in production."],
    [:name = "Flexibility", :desc = "No opinionated structure. Build your way."],
    [:name = "Reliability", :desc = "Battle-tested patterns. Consistent behavior."]
]

aMembers = [
    [:name = "Youssef Saeed", :initials = "YS", :role = "Creator", :bio = "Designer of the Bolt framework", :color = "#c45d3a", :active = true]
]

aSubjects = ["General Inquiry", "Bug Report", "Feature Request", "Partnership"]

aContactInfo = [
    [:icon = "📧", :label = "Email", :value = "hello@boltframework.dev"],
    [:icon = "🌐", :label = "Website", :value = "https://boltframework.dev"],
    [:icon = "💬", :label = "Chat", :value = "Discord: bolt-community"],
    [:icon = "📍", :label = "Location", :value = "Open Source - Worldwide"]
]

aHours = [
    [:day = "Monday - Friday", :time = "9:00 AM - 6:00 PM", :open = true],
    [:day = "Saturday", :time = "10:00 AM - 2:00 PM", :open = true],
    [:day = "Sunday", :time = "", :open = false]
]

new Bolt() {
    port = 3000
    enableLogging()

    # ===========================================
    # Landing page
    # ===========================================
    @get("/", func {
        $bolt.html('
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Bolt Templates</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif; background: #f8f9fa; color: #212529; }
        .container { max-width: 720px; margin: 40px auto; padding: 0 20px; }
        .card { background: white; border-radius: 10px; box-shadow: 0 2px 8px rgba(0,0,0,0.08); padding: 30px; margin-bottom: 24px; }
        h1 { margin-bottom: 8px; font-size: 28px; }
        .subtitle { color: #6c757d; margin-bottom: 30px; }
        .section-title { font-size: 18px; font-weight: 700; margin-bottom: 14px; }
        .demo-list { list-style: none; display: grid; gap: 8px; }
        .demo-list a { display: block; padding: 10px 14px; background: #f8f9fa; border-radius: 6px; color: #007bff; text-decoration: none; transition: background 0.15s; }
        .demo-list a:hover { background: #e9ecef; }
        .demo-list a span { float: right; color: #6c757d; font-size: 13px; }
        .badge { display: inline-block; padding: 3px 8px; border-radius: 10px; font-size: 11px; font-weight: 600; margin-left: 6px; }
        .badge-inline { background: #d1ecf1; color: #0c5460; }
        .badge-file { background: #d4edda; color: #155724; }
        hr { border: none; border-top: 1px solid #dee2e6; margin: 20px 0; }
    </style>
</head>
<body>
<div class="container">
    <h1>Bolt Template Examples</h1>
    <p class="subtitle">MiniJinja-powered templating with two approaches</p>

    <div class="card">
        <h2 class="section-title">render() <span class="badge badge-inline">inline</span></h2>
        <p style="color: #6c757d; font-size: 14px; margin-bottom: 14px;">Template strings embedded directly in Ring code — great for quick prototypes and small snippets.</p>
        <ul class="demo-list">
            <li><a href="/render/hello/World">Variable substitution<span>Hello, World!</span></a></li>
            <li><a href="/render/users">Loops<span>User list</span></a></li>
            <li><a href="/render/status/200">Conditionals — 200<span>Success</span></a></li>
            <li><a href="/render/status/404">Conditionals — 404<span>Not found</span></a></li>
            <li><a href="/render/status/500">Conditionals — 500<span>Server error</span></a></li>
            <li><a href="/render/products">Complex template<span>Product catalog</span></a></li>
        </ul>
    </div>

    <div class="card">
        <h2 class="section-title">renderFile() <span class="badge badge-file">file-based</span></h2>
        <p style="color: #6c757d; font-size: 14px; margin-bottom: 14px;">External .html files with MiniJinja inheritance — ideal for larger projects with shared layouts.</p>
        <ul class="demo-list">
            <li><a href="/home">Home page<span>Features &amp; stats</span></a></li>
            <li><a href="/about">About page<span>Timeline &amp; values</span></a></li>
            <li><a href="/team">Team page<span>Member cards</span></a></li>
            <li><a href="/contact">Contact page<span>Form with validation</span></a></li>
        </ul>
    </div>
</div>
</body>
</html>
        ')
    })

    # ===========================================
    # render() — Inline templates
    # ===========================================

    @get("/render/hello/:name", func {
        cName = $bolt.param("name")

        $bolt.render('
<!DOCTYPE html>
<html>
<head><title>Hello {{ name }}</title></head>
<body>
    <h1>Hello, {{ name }}!</h1>
    <p>Welcome to Bolt Framework</p>
</body>
</html>
        ', [
            [:name, cName]
        ])
    })

    @get("/render/users", func {
        $bolt.render('
<!DOCTYPE html>
<html>
<body>
    <h1>Users List</h1>
    <ul>
    {% for user in users %}
        <li>{{ user.name }} ({{ user.email }})</li>
    {% endfor %}
    </ul>
</body>
</html>
        ', [
            [:users, [
                [:name = "Alice", :email = "alice@example.com"],
                [:name = "Bob", :email = "bob@example.com"],
                [:name = "Charlie", :email = "charlie@example.com"]
            ]]
        ])
    })

    @get("/render/status/:code", func {
        cCode = $bolt.param("code")
        nCode = 0 + cCode

        $bolt.render('
<!DOCTYPE html>
<html>
<body>
    <h1>Status: {{ code }}</h1>

    {% if code >= 200 and code < 300 %}
        <p style="color: green">✓ Success!</p>
    {% elif code >= 400 and code < 500 %}
        <p style="color: orange">⚠ Client Error</p>
    {% elif code >= 500 %}
        <p style="color: red">✗ Server Error</p>
    {% else %}
        <p>Unknown status</p>
    {% endif %}
</body>
</html>
        ', [
            :code = nCode
        ])
    })

    @get("/render/products", func {
        $bolt.render('
<!DOCTYPE html>
<html>
<head>
    <title>Products</title>
    <style>
        table { border-collapse: collapse; width: 100%; }
        th, td { border: 1px solid #ddd; padding: 8px; text-align: left; }
        th { background: #007bff; color: white; }
        .in-stock { color: green; }
        .out-of-stock { color: red; }
    </style>
</head>
<body>
    <h1>Product Catalog</h1>
    <table>
        <tr>
            <th>Name</th>
            <th>Price</th>
            <th>Stock</th>
        </tr>
        {% for product in products %}
        <tr>
            <td>{{ product.name }}</td>
            <td>${{ product.price }}</td>
            <td class="{% if product.stock > 0 %}in-stock{% else %}out-of-stock{% endif %}">
                {% if product.stock > 0 %}
                    {{ product.stock }} available
                {% else %}
                    Out of stock
                {% endif %}
            </td>
        </tr>
        {% endfor %}
    </table>
</body>
</html>
        ', [
            [:products, [
                [:name = "Laptop", :price = 999, :stock = 5],
                [:name = "Mouse", :price = 25, :stock = 0],
                [:name = "Keyboard", :price = 75, :stock = 12],
                [:name = "Monitor", :price = 350, :stock = 3]
            ]]
        ])
    })

    # ===========================================
    # renderFile() — External template files
    # ===========================================

    @get("/home", func {
        $bolt.renderFile("./templates/home.html", [
            :features = aFeatures,
            :stats = aStats
        ])
    })

    @get("/about", func {
        $bolt.renderFile("./templates/about.html", [
            :description = "Bolt is a high-performance web framework for the Ring programming language, designed for developers who value simplicity and speed.",
            :timeline = aTimeline,
            :values = aValues
        ])
    })

    @get("/team", func {
        $bolt.renderFile("./templates/team.html", [
            :members = aMembers
        ])
    })

    @get("/contact", func {
        $bolt.renderFile("./templates/contact.html", [
            :subjects = aSubjects,
            :contact_info = aContactInfo,
            :hours = aHours,
            :submitted = false,
            :name = "",
            :email = "",
            :subject = "General Inquiry",
            :message = "",
            :errors = []
        ])
    })

    @post("/contact", func {
        cName = $bolt.formField("name")
        cEmail = $bolt.formField("email")
        cSubject = $bolt.formField("subject")
        cMessage = $bolt.formField("message")

        aErrors = []
        if cName = "" or len(cName) < 2
            add(aErrors, "Name must be at least 2 characters")
        ok
        if cEmail = "" or not substr(cEmail, "@")
            add(aErrors, "A valid email address is required")
        ok
        if cMessage = "" or len(cMessage) < 10
            add(aErrors, "Message must be at least 10 characters")
        ok

        if len(aErrors) > 0
            $bolt.renderFile("./templates/contact.html", [
                :subjects = aSubjects,
                :contact_info = aContactInfo,
                :hours = aHours,
                :submitted = false,
                :name = cName,
                :email = cEmail,
                :subject = cSubject,
                :message = cMessage,
                :errors = aErrors
            ])
            return
        ok

        ? "Contact form: " + cName + " <" + cEmail + "> - " + cSubject

        $bolt.renderFile("./templates/contact.html", [
            :subjects = aSubjects,
            :contact_info = aContactInfo,
            :hours = aHours,
            :submitted = true,
            :name = cName,
            :email = cEmail,
            :subject = cSubject,
            :message = "",
            :errors = []
        ])
    })
}
