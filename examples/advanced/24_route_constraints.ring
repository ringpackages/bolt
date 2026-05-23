# Route Constraints - where() validation
# Run: ring 24_route_constraints.ring

load "bolt.ring"

new Bolt() {
    port = 3000
    
    # Numeric constraint
    # Works: /users/123
    # Fails: /users/abc
    @get("/users/:id", func {
        cId = $bolt.param("id")
        
        $bolt.json([
            [:message, "User found"],
            [:id, cId]
        ])
    })
    where("id", "^[0-9]+$")  # ^ and $ anchors are required!
    
    # UUID constraint
    # Works: /posts/550e8400-e29b-41d4-a716-446655440000
    # Fails: /posts/invalid-uuid
    @get("/posts/:uuid", func {
        cUuid = $bolt.param("uuid")
        
        $bolt.json([
            [:message, "Post found"],
            [:uuid, cUuid]
        ])
    })
    where("uuid", "^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$")
    
    
    # Alphanumeric username
    # Works: /profile/user123
    # Fails: /profile/user@123
    @get("/profile/:username", func {
        cUsername = $bolt.param("username")
        
        $bolt.json([
            [:message, "Profile found"],
            [:username, cUsername]
        ])
    })
    where("username", "^[a-zA-Z0-9]+$")
    
    
    # Date constraint (YYYY-MM-DD)
    # Works: /reports/2024-01-15
    # Fails: /reports/15-01-2024
    @get("/reports/:date", func {
        cDate = $bolt.param("date")
        
        $bolt.json([
            [:message, "Report for date"],
            [:date, cDate]
        ])
    })
    where("date", "^[0-9]{4}-[0-9]{2}-[0-9]{2}$")
    
    
    # Multiple constraints
    # Works: /api/v1/products/123
    # Fails: /api/v2/products/123 or /api/v1/products/abc
    @get("/api/:version/products/:id", func {
        cVersion = $bolt.param("version")
        cId = $bolt.param("id")
        
        $bolt.json([
            [:version, cVersion],
            [:productId, cId]
        ])
    })
    where("version", "^v1$")
    where("id", "^[0-9]+$")
    
    
    # Slug constraint (URL-friendly strings)
    # Works: /blog/my-first-post
    # Fails: /blog/My First Post
    @get("/blog/:slug", func {
        cSlug = $bolt.param("slug")
        
        $bolt.json([
            [:message, "Blog post"],
            [:slug, cSlug]
        ])
    })
    where("slug", "^[a-z0-9-]+$")
    
    
    @get("/", func {
        $bolt.html('<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Route Constraints</title>
    <style>
        :root { --bg: #0f0f1a; --surface: rgba(255,255,255,0.05); --text: #f1f5f9; --text-secondary: #94a3b8; --accent: #6366f1; --success: #10b981; --error: #ef4444; --border: rgba(255,255,255,0.08); --radius: 16px; --radius-sm: 10px; --transition: 0.25s cubic-bezier(0.4, 0, 0.2, 1); --font: Inter, system-ui, -apple-system, sans-serif; }
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { font-family: var(--font); background: var(--bg); background-image: radial-gradient(ellipse 80% 60% at 50% -20%, rgba(99,102,241,0.1), transparent), radial-gradient(ellipse 60% 50% at 80% 80%, rgba(16,185,129,0.05), transparent); color: var(--text); padding: 40px 20px; max-width: 800px; margin: 0 auto; min-height: 100vh; line-height: 1.6; -webkit-font-smoothing: antialiased; }
        h1 { font-size: 28px; font-weight: 700; letter-spacing: -0.5px; margin-bottom: 8px; }
        h2 { font-size: 18px; font-weight: 600; letter-spacing: -0.3px; }
        .subtitle { color: var(--text-secondary); margin-bottom: 32px; font-size: 15px; }
        .card { background: var(--surface); backdrop-filter: blur(12px); -webkit-backdrop-filter: blur(12px); border: 1px solid var(--border); border-radius: var(--radius); padding: 24px; margin-bottom: 18px; transition: all var(--transition); position: relative; overflow: hidden; }
        .card::before { content: ""; position: absolute; top: 0; left: 0; right: 0; height: 1px; background: linear-gradient(90deg, transparent, rgba(255,255,255,0.05), transparent); }
        .card:hover { border-color: rgba(255,255,255,0.15); background: rgba(255,255,255,0.08); box-shadow: 0 8px 32px rgba(0,0,0,0.3); transform: translateY(-1px); }
        .card h2 { margin-bottom: 16px; }
        .link-list { list-style: none; }
        .link-list li { display: flex; align-items: center; gap: 12px; padding: 10px 0; border-bottom: 1px solid var(--border); }
        .link-list li:last-child { border-bottom: none; }
        .link-list a { color: var(--accent); text-decoration: none; font-family: monospace; font-size: 14px; transition: color var(--transition); }
        .link-list a:hover { color: var(--accent-hover); text-decoration: underline; }
        .tag { display: inline-block; padding: 3px 10px; border-radius: 20px; font-size: 11px; font-weight: 600; letter-spacing: 0.01em; }
        .tag-valid { background: rgba(16,185,129,0.12); color: #6ee7b7; border: 1px solid rgba(16,185,129,0.2); }
        .tag-invalid { background: rgba(239,68,68,0.12); color: #fca5a5; border: 1px solid rgba(239,68,68,0.2); }
        pre { background: rgba(255,255,255,0.04); padding: 12px; border-radius: var(--radius-sm); font-size: 13px; overflow-x: auto; font-family: monospace; }
        code { background: rgba(255,255,255,0.04); padding: 2px 6px; border-radius: 4px; font-size: 13px; font-family: monospace; }
    </style>
</head>
<body>
    <h1>Route Constraints</h1>
    <p class="subtitle"><code>where()</code> validation with regex patterns</p>

    <div class="card">
        <h2>Valid URLs</h2>
        <ul class="link-list">
            <li><a href="/users/123">/users/123</a> <span class="tag tag-valid">numeric</span></li>
            <li><a href="/profile/user123">/profile/user123</a> <span class="tag tag-valid">alphanumeric</span></li>
            <li><a href="/reports/2024-01-15">/reports/2024-01-15</a> <span class="tag tag-valid">date</span></li>
            <li><a href="/api/v1/products/456">/api/v1/products/456</a> <span class="tag tag-valid">multiple</span></li>
            <li><a href="/blog/my-first-post">/blog/my-first-post</a> <span class="tag tag-valid">slug</span></li>
        </ul>
    </div>

    <div class="card">
        <h2>Invalid URLs (will return 400)</h2>
        <ul class="link-list">
            <li><a href="/users/abc">/users/abc</a> <span class="tag tag-invalid">numeric</span></li>
            <li><a href="/profile/user@123">/profile/user@123</a> <span class="tag tag-invalid">alphanumeric</span></li>
            <li><a href="/reports/15-01-2024">/reports/15-01-2024</a> <span class="tag tag-invalid">date</span></li>
            <li><a href="/api/v2/products/123">/api/v2/products/123</a> <span class="tag tag-invalid">version</span></li>
            <li><a href="/blog/My First Post">/blog/My First Post</a> <span class="tag tag-invalid">slug</span></li>
        </ul>
    </div>

    <div class="card">
        <h2>Regex Patterns</h2>
        <pre>Numeric:      ^[0-9]+$
Alphanumeric: ^[a-zA-Z0-9]+$
UUID:         ^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$
Date:         ^[0-9]{4}-[0-9]{2}-[0-9]{2}$
Slug:         ^[a-z0-9-]+$

Note: ^ and $ anchors are REQUIRED for proper validation.</pre>
    </div>
</body>
</html>
        ')
    })
}
