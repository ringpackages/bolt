# TLS/HTTPS - Secure Server
# Run: ring 42_tls_https.ring
# Demonstrates: enableTls, secure HTTPS server
# NOTE: Uses self-signed certs from tests/pytest/certs/

load "bolt.ring"

cDir = currentdir()

new Bolt() {
    port = 3000

    // Uncomment the line below to enable HTTPS
    // You need valid cert.pem and key.pem files
    // enableTls(cDir + "/certs/cert.pem", cDir + "/certs/key.pem")

    @get("/health", func {
        $bolt.json([:status = "ok", :tls = false, :note = "Set enableTls() and provide cert/key files to enable HTTPS"])
    })

    @get("/", func {
        $bolt.renderFile("./templates/layout.html", [
            :title = "Bolt - TLS/HTTPS",
            :subtitle = "Secure server with TLS certificates",
            :sections = [
                [:title = "How to Enable HTTPS", :code = `// 1. Generate self-signed certificates for development:
openssl req -x509 -newkey rsa:2048 -keyout key.pem -out cert.pem -days 365 -nodes

// 2. Enable TLS in your Bolt server:
new Bolt() {
    enableTls("cert.pem", "key.pem")
    // ... routes
}

// 3. Test with curl (skip cert verification for self-signed):
curl -k https://localhost:3000/`],
                [:title = "Current Status", :text = "TLS is currently disabled. Uncomment enableTls() and provide cert/key to enable."],
                [:title = "Configuration", :code = `enableTls(certPath, keyPath) -> Enable HTTPS with TLS certificate
ipWhitelist("127.0.0.1")    -> Only allow local connections
ipBlacklist("10.0.0.0/8")    -> Block private network range
proxyWhitelist("127.0.0.1")  -> Trust local proxy headers`]
            ]
        ])
    })

    @get("/info", func {
        $bolt.json([
            :host = $bolt.header("Host"),
            :clientIp = $bolt.clientIp(),
            :method = $bolt.method(),
            :tls = false
        ])
    })

    @get("/config", func {
        $bolt.json([
            :port = 3000,
            :tlsEnabled = false,
            :ipWhitelist = ["127.0.0.1"],
            :ipBlacklist = ["10.0.0.0/8"],
            :proxyWhitelist = ["127.0.0.1"]
        ])
    })

    ipWhitelist("127.0.0.1")
    ipBlacklist("10.0.0.0/8")
    proxyWhitelist("127.0.0.1")
}