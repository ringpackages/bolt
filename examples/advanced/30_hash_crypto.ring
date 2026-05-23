# Hash & Crypto - Password hashing and encryption
# Run: ring 30_hash_crypto.ring

load "bolt.ring"

hash = new Hash
crypto = new Crypto

cEncryptionKey = "0123456789abcdef0123456789abcdef"

new Bolt() {
    port = 3000

    # Argon2 password hashing (recommended)
    @post("/hash/argon2", func {
        data = $bolt.jsonBody()
        cHashed = hash.argon2(data[:password])
        $bolt.json([:algorithm = "argon2id", :hash = cHashed])
    })

    @post("/hash/argon2/verify", func {
        data = $bolt.jsonBody()
        bValid = hash.verifyArgon2(data[:password], data[:hash])
        $bolt.json([:valid = bValid])
    })

    # Bcrypt password hashing
    @post("/hash/bcrypt", func {
        data = $bolt.jsonBody()
        cHashed = hash.bcrypt(data[:password])
        $bolt.json([:algorithm = "bcrypt", :hash = cHashed])
    })

    @post("/hash/bcrypt/verify", func {
        data = $bolt.jsonBody()
        bValid = hash.verifyBcrypt(data[:password], data[:hash])
        $bolt.json([:valid = bValid])
    })

    # Scrypt password hashing
    @post("/hash/scrypt", func {
        data = $bolt.jsonBody()
        cHashed = hash.scrypt(data[:password])
        $bolt.json([:algorithm = "scrypt", :hash = cHashed])
    })

    @post("/hash/scrypt/verify", func {
        data = $bolt.jsonBody()
        bValid = hash.verifyScrypt(data[:password], data[:hash])
        $bolt.json([:valid = bValid])
    })

    # Full registration + login flow with Argon2
    cStoredHash = ""

    @post("/register", func {
        data = $bolt.jsonBody()
        cStoredHash = hash.argon2(data[:password])
        $bolt.json([:registered = true, :hash = cStoredHash])
    })

    @post("/login", func {
        data = $bolt.jsonBody()
        if hash.verifyArgon2(data[:password], cStoredHash)
            $bolt.json([:success = true, :message = "Login successful"])
        else
            $bolt.jsonWithStatus(401, [:success = false, :error = "Invalid password"])
        ok
    })

    # AES-256-GCM encryption
    @post("/crypto/encrypt", func {
        data = $bolt.jsonBody()
        cEncrypted = crypto.aesEncrypt(data[:plaintext], cEncryptionKey)
        $bolt.json([:encrypted = cEncrypted, :algorithm = "AES-256-GCM"])
    })

    @post("/crypto/decrypt", func {
        data = $bolt.jsonBody()
        cDecrypted = crypto.aesDecrypt(data[:ciphertext], cEncryptionKey)
        $bolt.json([:decrypted = cDecrypted])
    })

    # HMAC-SHA256 signatures
    @post("/crypto/hmac/sign", func {
        data = $bolt.jsonBody()
        cSig = crypto.hmacSha256(data[:message], data[:key])
        $bolt.json([:signature = cSig, :algorithm = "HMAC-SHA256"])
    })

    @post("/crypto/hmac/verify", func {
        data = $bolt.jsonBody()
        bValid = crypto.hmacVerify(data[:message], data[:key], data[:signature])
        $bolt.json([:valid = bValid])
    })

    @get("/", func {
        cArgon = `curl -X POST http://localhost:3000/hash/argon2 -H 'Content-Type: application/json' -d '{"password":"mypassword"}'`
        cArgonVerify = `curl -X POST http://localhost:3000/hash/argon2/verify -H 'Content-Type: application/json' -d '{"password":"mypassword","hash":"HASH_HERE"}'`
        cBcrypt = `curl -X POST http://localhost:3000/hash/bcrypt -H 'Content-Type: application/json' -d '{"password":"mypassword"}'`
        cScrypt = `curl -X POST http://localhost:3000/hash/scrypt -H 'Content-Type: application/json' -d '{"password":"mypassword"}'`
        cRegister = `curl -X POST http://localhost:3000/register -H 'Content-Type: application/json' -d '{"password":"secret123"}'`
        cLogin = `curl -X POST http://localhost:3000/login -H 'Content-Type: application/json' -d '{"password":"secret123"}'`
        cEncrypt = `curl -X POST http://localhost:3000/crypto/encrypt -H 'Content-Type: application/json' -d '{"plaintext":"secret data"}'`
        cDecrypt = `curl -X POST http://localhost:3000/crypto/decrypt -H 'Content-Type: application/json' -d '{"ciphertext":"CIPHERTEXT_HERE"}'`
        cSign = `curl -X POST http://localhost:3000/crypto/hmac/sign -H 'Content-Type: application/json' -d '{"message":"hello","key":"my-key"}'`
        cVerify = `curl -X POST http://localhost:3000/crypto/hmac/verify -H 'Content-Type: application/json' -d '{"message":"hello","key":"my-key","signature":"SIG_HERE"}'`

        $bolt.renderFile("./templates/layout.html", [
            :title = "Bolt - Hash & Crypto",
            :subtitle = "Password hashing, AES encryption, HMAC signatures",
            :sections = [
                [:title = "Password Hashing", :subsections = [
                    [:title = "Argon2 (recommended)", :code = cArgon + nl + cArgonVerify],
                    [:title = "Bcrypt", :code = cBcrypt],
                    [:title = "Scrypt", :code = cScrypt],
                    [:title = "Register + Login flow", :code = cRegister + nl + cLogin]
                ]],
                [:title = "Encryption (AES-256-GCM)", :subsections = [
                    [:title = "Encrypt", :code = cEncrypt],
                    [:title = "Decrypt", :code = cDecrypt]
                ]],
                [:title = "HMAC-SHA256", :subsections = [
                    [:title = "Sign", :code = cSign],
                    [:title = "Verify", :code = cVerify]
                ]]
            ]
        ])
    })
}
