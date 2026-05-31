load "bolt.ring"

new Bolt() {
    cPort = sysget("BOLT_TEST_PORT")
    if cPort = "" { cPort = "3000" }
    port = number(cPort)

    @error(:error_handler)

    @get("/health", func {
        $bolt.json([:status = "ok"])
    })

    @get("/params/:id", func {
        $bolt.json([:id = $bolt.param("id")])
    })
    where("id", "[0-9]+")

    @get("/rate-limit/route", func {
        $bolt.json([:ok = 1])
    })
    routeRateLimit(2, 60)

    @static("/public", "tests/static_test")

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

    @get("/json-encode/bad", func {
        result = $bolt.jsonEncode("not a list")
        $bolt.json([:result = result])
    })

    @get("/render-file/traversal", func {
        $bolt.renderFile("../../../../etc/passwd", [:name = "hack"])
    })

    @post("/multipart-size", func {
        nCount = $bolt.filesCount()
        $bolt.json([:files = nCount])
    })

    setMultipartFieldSizeLimit(50)

    @get("/template/syntax", func {
        $bolt.render("{% if %}", [])
    })

    @get("/env/missing-file", func {
        env = new Env
        env.loadFile("/nonexistent/path/.env")
        $bolt.json([:ok = 1])
    })

    @get("/base64/url-bad", func {
        result = $bolt.baseUrlDecode("!!!not-base64!!!")
        $bolt.json([:result = result])
    })

    @get("/validate/json-errors", func {
        schema = '{"type":"object","properties":{"name":{"type":"string","minLength":1}},"required":["name"]}'
        errors = $bolt.validateJsonErrors('{"name":""}', schema)
        $bolt.json([:errors = errors])
    })

    @get("/validate/json-valid", func {
        schema = '{"type":"object","properties":{"name":{"type":"string","minLength":1}},"required":["name"]}'
        errors = $bolt.validateJsonErrors('{"name":"alice"}', schema)
        $bolt.json([:errors = errors])
    })

    @get("/set-port-host", func {
        $bolt.setPort(9999)
        $bolt.setHost("127.0.0.1")
        $bolt.json([:set = 1])
    })
}

func error_handler
    errMsg = $bolt.body()
    $bolt.jsonWithStatus(500, [:error = 1, :caught = 1, :message = errMsg])
