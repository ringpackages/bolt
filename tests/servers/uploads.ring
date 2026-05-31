load "bolt.ring"


new Bolt() {
    cPort = sysget("BOLT_TEST_PORT")
    if cPort = "" { cPort = "3000" }
    port = number(cPort)

    @get("/health", func {
        $bolt.json([:status = "ok"])
    })

    @post("/upload", func {
        nCount = $bolt.filesCount()
        if nCount < 1 {
            $bolt.badRequest("No files uploaded")
            return
        }
        aFiles = []
        for i = 1 to nCount
            f = $bolt.file(i)
            aFiles + [:name = f[:name], :field = f[:field], :type = f[:type], :size = f[:size]]
        next
        $bolt.json([:count = nCount, :files = aFiles])
    })

    @post("/upload/all", func {
        aFiles = $bolt.files()
        if len(aFiles) < 1 {
            $bolt.badRequest("No files")
            return
        }
        $bolt.json([:count = len(aFiles), :files = aFiles])
    })

    @post("/upload/save", func {
        if $bolt.filesCount() < 1 {
            $bolt.badRequest("No file")
            return
        }
        f = $bolt.file(1)
        path = "tests/upload_test_" + f[:name]
        ok = $bolt.fileSave(1, path)
        $bolt.json([:saved = ok, :path = path])
    })

    @post("/upload/by-field", func {
        f = $bolt.fileByField("avatar")
        if isNull(f) {
            $bolt.badRequest("No avatar field")
            return
        }
        $bolt.json([:file = [:name = f[:name], :type = f[:type], :size = f[:size]]])
    })

    @post("/form", func {
        $bolt.json([:username = $bolt.formField("username"), :email = $bolt.formField("email")])
    })

    @post("/form-multi", func {
        tags = $bolt.formFieldAll("tag")
        $bolt.json([:tags = tags])
    })

    @post("/body-base64", func {
        b64 = $bolt.bodyBase64()
        $bolt.json([:base64 = b64])
    })
}
