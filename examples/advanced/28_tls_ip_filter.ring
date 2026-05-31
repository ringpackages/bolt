# TLS/HTTPS, IP Filtering & Server Configuration
# Run: ring 28_tls_ip_filter.ring
# Note: For TLS, you need cert.pem and key.pem files.
#       Generate: openssl req -x509 -newkey rsa:2048 -keyout key.pem -out cert.pem -days 365 -nodes

load "bolt.ring"

new Bolt() {
    port = 3000

    # Enable TLS (uncomment when you have cert files)
    # enableTls("cert.pem", "key.pem")
    # port = 443

    # IP Whitelist - only allow these IPs/CIDRs
    ipWhitelist("127.0.0.1")
    ipWhitelist("192.168.1.0/24")
    ipWhitelist("10.0.0.0/8")

    # IP Blacklist - block specific IPs
    ipBlacklist("1.2.3.4")
    ipBlacklist("5.6.7.0/24")

    # Proxy whitelist - trust these proxies for X-Forwarded-For
    proxyWhitelist("10.0.0.1")
    proxyWhitelist("192.168.1.1")

    # Server configuration
    setTimeout(30000)
    setBodyLimit(10 * 1024 * 1024)
    setSessionCapacity(50000)
    setSessionTTL(3600)
    setCacheCapacity(50000)
    setCacheTTL(600)

    @get("/", func {
        cIp = $bolt.clientIp()
        $bolt.json([
            :message = "Access granted",
            :your_ip = cIp,
            :note = "Only whitelisted IPs can access this server"
        ])
    })

    @get("/config", func {
        $bolt.json([
            :timeout_ms = 30000,
            :body_limit = "10MB",
            :session_capacity = 50000,
            :session_ttl = "1 hour",
            :cache_capacity = 50000,
            :cache_ttl = "10 minutes"
        ])
    })

    # HTTPS redirect middleware (use behind a reverse proxy)
    @before(func {
        cProto = $bolt.header("X-Forwarded-Proto")
        if cProto = "http"
            $bolt.redirectPermanent("https://" + $bolt.header("Host") + $bolt.path())
        ok
    })

    @get("/info", func {
        $bolt.renderFile("./templates/layout.html", [
            :title = "Bolt - TLS & IP Filtering",
            :subtitle = "HTTPS, IP whitelist/blacklist, proxy trust",
            :sections = [
                [:title = "Test with curl", :subsections = [
                    [:title = "Get client IP info", :code = "curl http://localhost:3000/"],
                    [:title = "View server config", :code = "curl http://localhost:3000/config"],
                    [:title = "View TLS and IP info", :code = "curl http://localhost:3000/info"]
                ]],
                [:title = "Whitelisted IPs", :items = [
                    "127.0.0.1, 192.168.1.0/24, 10.0.0.0/8"
                ]],
                [:title = "Blacklisted IPs", :items = [
                    "1.2.3.4, 5.6.7.0/24"
                ]],
                [:title = "Server Config", :code = `Timeout: 30s, Body limit: 10MB
Session: 50k entries, 1h TTL
Cache: 50k entries, 10min TTL`],
                [:title = "TLS Setup", :code = `# Generate self-signed cert:
openssl req -x509 -newkey rsa:2048 -keyout key.pem -out cert.pem -days 365 -nodes

# Then uncomment enableTls() in source`]
            ]
        ])
    })
}
