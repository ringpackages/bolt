load "bolt.ring"

testDir = sysget("BOLT_TEST_DIR")

new Bolt() {
    cPort = sysget("BOLT_TEST_PORT")
    if cPort = "" { cPort = "3000" }
    port = number(cPort)

    setBodyLimit(100)
    setMultipartFieldCountLimit(2)
    setMultipartFieldSizeLimit(50)
    forceSecureCookies()
    setTimeout(2000)

    @get("/health", func {
        $bolt.json([:status = "ok"])
    })

    @post("/body-check", func {
        $bolt.json([:received = $bolt.body()])
    })

    @post("/multipart-check", func {
        nCount = $bolt.filesCount()
        username = $bolt.formField("username")
        $bolt.json([:files = nCount, :username = username])
    })

    @get("/session/secure-cookie", func {
        $bolt.setSession("test", "value")
        val = $bolt.getSession("test")
        $bolt.json([:value = val])
    })

    @static("/public", "tests/static_test")

    ipWhitelist("127.0.0.1")
    ipBlacklist("10.0.0.1")
    proxyWhitelist("127.0.0.1")

    @get("/ip-check", func {
        $bolt.json([:ip = $bolt.clientIp()])
    })

    setCookieSecret("test-secret-key-at-least-32-chars!!")

    @get("/signed/set", func {
        $bolt.setSignedCookie("user", "alice")
        $bolt.json([:set = 1])
    })

    @get("/signed/read", func {
        user = $bolt.getSignedCookie("user")
        $bolt.json([:user = user])
    })

    @get("/cookie/full", func {
        $bolt.setCookieEx("prefs", "dark", "Path=/; Max-Age=3600; HttpOnly; SameSite=Strict")
        $bolt.json([:set = 1])
    })

    @get("/cookie/read", func {
        prefs = $bolt.cookie("prefs")
        $bolt.json([:prefs = prefs])
    })

    @get("/etag/conditional", func {
        content = $bolt.jsonEncode([:data = "cached"])
        etagVal = $bolt.etag(content)
        $bolt.setHeader("ETag", etagVal)
        ifNoneMatch = $bolt.header("If-None-Match")
        if ifNoneMatch = etagVal {
            $bolt.sendStatus(304)
        else
            $bolt.send(content)
        }
    })

    @get("/render", func {
        $bolt.render("<h1>Hello {{ name }}!</h1>", [:name = "Render"])
    })

    @get("/render-file", func {
        $bolt.renderFile("tests/templates/greeting.html", [:name = "FileRender"])
    })

    setCacheTTL(2)

    @get("/cache/ttl", func {
        $bolt.cacheSet("ttl_key", "ttl_value")
        val = $bolt.cacheGet("ttl_key")
        $bolt.json([:value = val])
    })

    @get("/cache/ttl/expired", func {
        val = $bolt.cacheGet("ttl_key")
        if val = "" { val = "(expired)" }
        $bolt.json([:value = val])
    })

    setSessionTTL(2)

    @get("/session/ttl", func {
        $bolt.setSession("ttl_key", "ttl_value")
        val = $bolt.getSession("ttl_key")
        $bolt.json([:value = val])
    })

    @get("/session/ttl/expired", func {
        val = $bolt.getSession("ttl_key")
        if val = "" { val = "(expired)" }
        $bolt.json([:value = val])
    })

    @get("/respond-file/traversal", func {
        $bolt.sendFile("../../etc/passwd")
    })

    @get("/respond-file/absolute", func {
        $bolt.sendFile("/etc/passwd")
    })

    @get("/respond-file/nul", func {
        $bolt.sendFile("test" + char(0) + "file.txt")
    })

    @post("/upload/save-absolute", func {
        if $bolt.filesCount() < 1 {
            $bolt.badRequest("No file")
            return
        }
        ok = $bolt.fileSave(1, "/tmp/stolen.txt")
        $bolt.json([:saved = ok])
    })

    @post("/upload/save-nul", func {
        if $bolt.filesCount() < 1 {
            $bolt.badRequest("No file")
            return
        }
        ok = $bolt.fileSave(1, "test" + char(0) + "file.txt")
        $bolt.json([:saved = ok])
    })

    @get("/cookie/bad", func {
        $bolt.setCookie("bad" + char(31) + "name", "value")
        $bolt.json([:set = 1])
    })

    @get("/template/error", func {
        $bolt.render("{{ undefined_var }}", [])
    })

    @get("/aes/wrong-key", func {
        enc = $bolt.aesEncrypt("hello", "0123456789abcdef0123456789abcdef")
        dec = $bolt.aesDecrypt(enc, "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa")
        $bolt.json([:decrypted = dec])
    })

    @get("/base64/bad", func {
        result = $bolt.base64Decode("!!!not-base64!!!")
        $bolt.json([:result = result])
    })

    @get("/rate-limit/route", func {
        $bolt.json([:ok = 1])
    })
    routeRateLimit(2, 60)

    @get("/params/:id", func {
        $bolt.json([:id = $bolt.param("id")])
    })
    where("id", "[0-9]+")

    @get("/static-missing", func {
        $bolt.sendFile("tests/nonexistent_file_12345.txt")
    })

    @get("/render-file/traversal", func {
        $bolt.renderFile("../../../../etc/passwd", [:name = "hack"])
    })

    @get("/json-encode/bad", func {
        result = $bolt.jsonEncode("not a list")
        $bolt.json([:result = result])
    })
}
