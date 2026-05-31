load "bolt.ring"

testDir = sysget("BOLT_TEST_DIR")

new Bolt() {
    cPort = sysget("BOLT_TEST_PORT")
    if cPort = "" { cPort = "3000" }
    port = number(cPort)

    @get("/health", func {
        $bolt.json([:status = "ok"])
    })

    @post("/validate/json", func {
        schema = '{"type":"object","properties":{"name":{"type":"string","minLength":1},"age":{"type":"integer","minimum":0,"maximum":150}},"required":["name","age"]}'
        if $bolt.validateJson($bolt.body(), schema) {
            data = $bolt.jsonBody()
            $bolt.json([:valid = 1, :data = data])
        else
            errors = $bolt.validateJsonErrors($bolt.body(), schema)
            $bolt.jsonWithStatus(400, [:valid = 0, :errors = errors])
        }
    })

    @get("/validate/param/:value", func {
        valid = $bolt.validateParam("value", "[0-9]+")
        $bolt.json([:value = $bolt.param("value"), :isNumeric = valid])
    })

    @get("/validate/regex", func {
        test = $bolt.query("test")
        result = $bolt.matchRegex(test, "^[a-z]+$")
        $bolt.json([:test = test, :matches = result])
    })

    @get("/template/inline", func {
        name = $bolt.query("name")
        if name = "" { name = "World" }
        $bolt.render("<h1>Hello {{ name }}!</h1>", [:name = name])
    })

    @get("/template/loop", func {
        n = number($bolt.query("count"))
        aItems = []
        for i = 1 to n
            aItems + [:num = i]
        next
        $bolt.render("<ul>{% for item in items %}<li>{{ item.num }}</li>{% endfor %}</ul>", [:items = aItems])
    })

    @get("/template/file", func {
        $bolt.renderFile(testDir + "/templates/greeting.html", [:name = "Bolt"])
    })

    @get("/json/pretty", func {
        $bolt.send($bolt.jsonPretty([:hello = "world", :nums = [1, 2, 3]]))
    })

    @get("/utils/uuid", func {
        $bolt.json([:uuid = $bolt.uuid()])
    })

    @get("/utils/sha256", func {
        text = $bolt.query("text")
        $bolt.json([:text = text, :hash = $bolt.sha256(text)])
    })

    @get("/utils/url-encode", func {
        text = $bolt.query("text")
        $bolt.json([:original = text, :encoded = $bolt.urlEncode(text)])
    })

    @get("/utils/url-decode", func {
        text = $bolt.query("text")
        $bolt.json([:encoded = text, :decoded = $bolt.urlDecode(text)])
    })

    @get("/utils/unixtime", func {
        $bolt.json([:seconds = $bolt.unixtime(), :milliseconds = $bolt.unixtimeMs()])
    })

    @get("/env/load-file", func {
        env = new Env
        env.loadFile(testDir + "/test.env")
        $bolt.json([:value = env.getOr("TEST_ENV_VAR", "(not found)")])
    })

    @post("/env/set", func {
        data = $bolt.jsonBody()
        sysset(data[:key], data[:value])
        $bolt.json([:set = 1])
    })

    @get("/env/key/:name", func {
        env = new Env
        name = $bolt.param("name")
        value = env.getOr(name, "(not set)")
        $bolt.json([:key = name, :value = value])
    })

    @get("/base64/encode", func {
        text = $bolt.query("text")
        $bolt.json([:original = text, :encoded = $bolt.base64Encode(text)])
    })

    @get("/base64/decode", func {
        encoded = $bolt.query("encoded")
        $bolt.json([:encoded = encoded, :decoded = $bolt.base64Decode(encoded)])
    })

    @get("/base64/url-encode", func {
        text = $bolt.query("text")
        $bolt.json([:original = text, :encoded = $bolt.base64UrlEncode(text)])
    })

    @get("/base64/url-decode", func {
        encoded = $bolt.query("encoded")
        $bolt.json([:encoded = encoded, :decoded = $bolt.base64UrlDecode(encoded)])
    })

    @post("/validate/inputs", func {
        data = $bolt.jsonBody()
        v = new Validate
        $bolt.json([
            :email = v.email(data[:email]),
            :url = v.url(data[:url]),
            :ip = v.ip(data[:ip]),
            :ipv4 = v.ipv4(data[:ipv4]),
            :ipv6 = v.ipv6(data[:ipv6]),
            :uuid = v.uuid(data[:uuid]),
            :jsonString = v.jsonString(data[:jsonString]),
            :alpha = v.alpha(data[:alpha]),
            :alphanumeric = v.alphanumeric(data[:alphanumeric]),
            :numeric = v.numeric(data[:numeric]),
            :length = v.length(data[:str], number(data[:min]), number(data[:max])),
            :range = v.range(number(data[:num]), number(data[:lo]), number(data[:hi]))
        ])
    })

    @post("/hash/argon2", func {
        data = $bolt.jsonBody()
        h = new Hash
        hashed = h.argon2(data[:password])
        $bolt.json([:hash = hashed])
    })

    @post("/hash/verify", func {
        data = $bolt.jsonBody()
        h = new Hash
        $bolt.json([:argon2 = h.verifyArgon2(data[:password], data[:hash])])
    })

    @post("/hash/bcrypt", func {
        data = $bolt.jsonBody()
        h = new Hash
        hashed = h.bcrypt(data[:password])
        $bolt.json([:hash = hashed])
    })

    @post("/hash/bcrypt-verify", func {
        data = $bolt.jsonBody()
        h = new Hash
        $bolt.json([:valid = h.verifyBcrypt(data[:password], data[:hash])])
    })

    @post("/hash/scrypt", func {
        data = $bolt.jsonBody()
        h = new Hash
        hashed = h.scrypt(data[:password])
        $bolt.json([:hash = hashed])
    })

    @post("/hash/scrypt-verify", func {
        data = $bolt.jsonBody()
        h = new Hash
        $bolt.json([:valid = h.verifyScrypt(data[:password], data[:hash])])
    })

    @post("/crypto/encrypt-decrypt", func {
        data = $bolt.jsonBody()
        c = new Crypto
        encrypted = c.aesEncrypt(data[:plaintext], data[:key])
        decrypted = c.aesDecrypt(encrypted, data[:key])
        $bolt.json([:encrypted = encrypted, :decrypted = decrypted])
    })

    @post("/crypto/hmac", func {
        data = $bolt.jsonBody()
        c = new Crypto
        sig = c.hmacSha256(data[:message], data[:key])
        valid = c.hmacVerify(data[:message], data[:key], sig)
        $bolt.json([:signature = sig, :valid = valid])
    })

    @get("/datetime", func {
        dt = new DateTime
        ts = dt.timestamp()
        tsMs = dt.timestampMs()
        formatted = dt.formatDate(ts, "%Y-%m-%d %H:%M:%S")
        nowLocal = dt.now()
        nowUtc = dt.nowUtc()
        $bolt.json([
            :timestamp = ts,
            :timestampMs = tsMs,
            :formatted = formatted,
            :now = nowLocal,
            :nowUtc = nowUtc
        ])
    })

    @get("/datetime/arithmetic", func {
        dt = new DateTime
        ts = dt.timestamp()
        plus2d = dt.addDays(ts, 2)
        plus3h = dt.addHours(ts, 3)
        diff = dt.diff(plus2d, ts)
        parsed = dt.parseDate("2024-01-15 10:30:00", "%Y-%m-%d %H:%M:%S")
        $bolt.json([
            :base = ts,
            :plus2days = plus2d,
            :plus3hours = plus3h,
            :diff_seconds = diff,
            :parsed = parsed
        ])
    })

    @post("/sanitize/html", func {
        data = $bolt.jsonBody()
        s = new Sanitize
        $bolt.json([:safe = s.html(data[:input]), :strict = s.strict(data[:input]), :escaped = s.escapeHtml(data[:input])])
    })

    @post("/sanitize/extra", func {
        data = $bolt.jsonBody()
        s = new Sanitize
        $bolt.json([
            :escapeAttr = s.escapeAttr(data[:input]),
            :escapeJs = s.escapeJs(data[:input]),
            :escapeUrl = s.escapeUrl(data[:input])
        ])
    })
}
