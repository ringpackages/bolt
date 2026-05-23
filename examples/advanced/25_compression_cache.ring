# Compression & Caching - Performance Optimization
# Run: ring 25_compression_cache.ring

load "bolt.ring"

new Bolt() {
    port = 3000
    
    # Enable compression for all responses
    enableCompression()
    
    # Large text response (benefits from compression)
    # curl -i http://localhost:3000/large --compressed
    @get("/large", func {
        cText = ""
        
        for i = 1 to 1000
            cText += "This is line " + i + " of repeated text to demonstrate compression. "
        next
        
        $bolt.setHeader("Content-Type", "text/plain")
        $bolt.send(cText)
    })
    
    # JSON with compression
    # curl -i http://localhost:3000/api/data --compressed
    @get("/api/data", func {
        aData = []
        
        for i = 1 to 100
            aData + [
                :id = i,
                :name = "Item " + i,
                :description = "This is a description for item " + i,
                :timestamp = $bolt.unixtime()
            ]
        next
        
        $bolt.json([
            :success = true,
            :count = len(aData),
            :data = aData
        ])
    })
    
    # Cache-Control headers
    # curl -i http://localhost:3000/cached
    @get("/cached", func {
        # Cache for 1 hour
        $bolt.setHeader("Cache-Control", "public, max-age=3600")
        $bolt.setHeader("Expires", "" + ($bolt.unixtime() + 3600))
        
        $bolt.json([
            [:message, "This response can be cached for 1 hour"],
            [:timestamp, $bolt.unixtime()]
        ])
    })
    
    # No cache (always fresh)
    # curl -i http://localhost:3000/no-cache
    @get("/no-cache", func {
        $bolt.setHeader("Cache-Control", "no-store, no-cache, must-revalidate")
        $bolt.setHeader("Pragma", "no-cache")
        $bolt.setHeader("Expires", "0")
        
        $bolt.json([
            [:message, "This response should never be cached"],
            [:timestamp, $bolt.unixtime()]
        ])
    })
    
    # ETag support (conditional requests)
    # curl -i http://localhost:3000/etag
    @get("/etag", func {
        cData = "Static content that rarely changes"
        
        # Generate ETag (simple hash of content)
        cEtag = '"' + $bolt.sha256(cData) + '"'
        
        # Check if client has cached version
        cIfNoneMatch = $bolt.header("If-None-Match")
        
        if cIfNoneMatch = cEtag
            # Client has current version
            $bolt.setHeader("ETag", cEtag)
            $bolt.sendWithStatus(304, "")
        else
            # Send new version
            $bolt.setHeader("ETag", cEtag)
            $bolt.setHeader("Cache-Control", "public, max-age=86400")
            $bolt.send(cData)
        ok
    })
    
    # Static assets with long cache
    @get("/assets/:filename", func {
        cFilename = $bolt.param("filename")

        # In production, serve actual files
        # For demo, return sample content

        $bolt.setHeader("Cache-Control", "public, max-age=31536000, immutable")
        $bolt.setHeader("Content-Type", "text/css")

        $bolt.send("/* Cached CSS file: " + cFilename + " */")
    })

    # In-memory cache: set and get
    # curl http://localhost:3000/cache/set/key1/value1
    @get("/cache/set/:key/:value", func {
        cKey = $bolt.param("key")
        cValue = $bolt.param("value")
        $bolt.cacheSet(cKey, cValue)
        $bolt.json([:action = "set", :key = cKey, :value = cValue])
    })

    # curl http://localhost:3000/cache/get/key1
    @get("/cache/get/:key", func {
        cKey = $bolt.param("key")
        cValue = $bolt.cacheGet(cKey)
        $bolt.json([:key = cKey, :value = cValue, :found = cValue != ""])
    })

    # curl http://localhost:3000/cache/delete/key1
    @get("/cache/delete/:key", func {
        cKey = $bolt.param("key")
        $bolt.cacheDelete(cKey)
        $bolt.json([:action = "delete", :key = cKey])
    })

    # curl http://localhost:3000/cache/clear
    @get("/cache/clear", func {
        $bolt.cacheClear()
        $bolt.json([:action = "clear", :message = "All cache entries cleared"])
    })

    # Toggle compression
    # curl http://localhost:3000/compression/off
    @get("/compression/off", func {
        $bolt.disableCompression()
        $bolt.json([:compression = false, :message = "Compression disabled"])
    })

    # curl http://localhost:3000/compression/on
    @get("/compression/on", func {
        $bolt.enableCompression()
        $bolt.json([:compression = true, :message = "Compression enabled"])
    })

    @get("/", func {
        $bolt.html('<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Compression & Caching</title>
    <style>
        :root { --bg: #0f0f1a; --surface: rgba(255,255,255,0.05); --text: #f1f5f9; --text-secondary: #94a3b8; --accent: #6366f1; --border: rgba(255,255,255,0.08); --radius: 16px; --radius-sm: 10px; --transition: 0.25s cubic-bezier(0.4, 0, 0.2, 1); --font: Inter, system-ui, -apple-system, sans-serif; }
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { font-family: var(--font); background: var(--bg); background-image: radial-gradient(ellipse 80% 60% at 50% -20%, rgba(99,102,241,0.1), transparent), radial-gradient(ellipse 60% 50% at 80% 80%, rgba(16,185,129,0.05), transparent); color: var(--text); padding: 40px 20px; max-width: 800px; margin: 0 auto; min-height: 100vh; line-height: 1.6; -webkit-font-smoothing: antialiased; }
        h1 { font-size: 28px; font-weight: 700; letter-spacing: -0.5px; margin-bottom: 8px; }
        h2 { font-size: 18px; font-weight: 600; letter-spacing: -0.3px; }
        .subtitle { color: var(--text-secondary); margin-bottom: 32px; font-size: 15px; }
        .card { background: var(--surface); backdrop-filter: blur(12px); -webkit-backdrop-filter: blur(12px); border: 1px solid var(--border); border-radius: var(--radius); padding: 24px; margin-bottom: 18px; position: relative; overflow: hidden; }
        .card::before { content: ""; position: absolute; top: 0; left: 0; right: 0; height: 1px; background: linear-gradient(90deg, transparent, rgba(255,255,255,0.05), transparent); }
        .card h2 { margin-bottom: 12px; }
        .card p { color: var(--text-secondary); font-size: 14px; margin-bottom: 12px; }
        code { background: rgba(255,255,255,0.04); padding: 2px 6px; border-radius: 4px; font-size: 13px; font-family: monospace; }
        pre { background: rgba(255,255,255,0.04); padding: 12px; border-radius: var(--radius-sm); font-size: 13px; overflow-x: auto; margin-bottom: 12px; font-family: monospace; }
        ul { padding-left: 20px; }
        li { padding: 4px 0; color: var(--text-secondary); font-size: 14px; }
        li strong { color: var(--text); }
    </style>
</head>
<body>
    <h1>Compression & Caching</h1>
    <p class="subtitle">Performance optimization with compression, caching, and ETags</p>

    <div class="card">
        <h2>Test Compression</h2>
        <p>Use <code>curl -i --compressed</code> to see compression headers:</p>
        <pre>curl -i http://localhost:3000/large --compressed</pre>
        <p>Look for: <code>Content-Encoding: br</code></p>
    </div>

    <div class="card">
        <h2>Test Caching</h2>
        <p>Cached response (1 hour):</p>
        <pre>curl -i http://localhost:3000/cached</pre>
        <p>No cache:</p>
        <pre>curl -i http://localhost:3000/no-cache</pre>
    </div>

    <div class="card">
        <h2>Test ETag</h2>
        <p>First request (200):</p>
        <pre>curl -i http://localhost:3000/etag</pre>
        <p>Second request with ETag (304 Not Modified):</p>
        <pre>curl -i http://localhost:3000/etag -H "If-None-Match: ETAG_FROM_FIRST_REQUEST"</pre>
    </div>

    <div class="card">
        <h2>Performance Benefits</h2>
        <ul>
            <li><strong>Compression:</strong> Reduces bandwidth by 60-80%</li>
            <li><strong>Caching:</strong> Reduces server load, faster responses</li>
            <li><strong>ETags:</strong> Conditional requests save bandwidth</li>
        </ul>
    </div>
</body>
</html>
        ')
    })
}
