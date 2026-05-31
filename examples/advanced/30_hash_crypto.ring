# Hash & Crypto - Password hashing and encryption
# Run: ring 30_hash_crypto.ring

load "bolt.ring"

hash = new Hash
crypto = new Crypto

# Load encryption key from environment (must be 32 chars)
# NEVER use sequential/weak keys in production
env = new Env()
cEncryptionKey = env.getOr("ENCRYPTION_KEY", "bolt-demo-change-me-in-production!!")
if env.getVar("ENCRYPTION_KEY") = ""
    ? "WARNING: ENCRYPTION_KEY not set, using insecure default"
ok

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
        # Never return password hashes to the client
        $bolt.json([:registered = true, :message = "Registration successful. Hash stored securely."])
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
        $bolt.renderFile("./templates/layout.html", [
            :title = "Bolt - Hash & Crypto",
            :subtitle = "Password hashing, AES encryption, HMAC signatures",
            :sections = [
                [:title = "Password Hashing", :subsections = [
                    [:title = "Argon2 (recommended)", :code = `curl -X POST http://localhost:3000/hash/argon2 -H 'Content-Type: application/json' -d '{"password":"mypassword"}'`],
                    [:title = "Argon2 verify", :code = `curl -X POST http://localhost:3000/hash/argon2/verify -H 'Content-Type: application/json' -d '{"password":"mypassword","hash":"HASH_HERE"}'`],
                    [:title = "Bcrypt", :code = `curl -X POST http://localhost:3000/hash/bcrypt -H 'Content-Type: application/json' -d '{"password":"mypassword"}'`],
                    [:title = "Bcrypt verify", :code = `curl -X POST http://localhost:3000/hash/bcrypt/verify -H 'Content-Type: application/json' -d '{"password":"mypassword","hash":"HASH_HERE"}'`],
                    [:title = "Scrypt", :code = `curl -X POST http://localhost:3000/hash/scrypt -H 'Content-Type: application/json' -d '{"password":"mypassword"}'`],
                    [:title = "Scrypt verify", :code = `curl -X POST http://localhost:3000/hash/scrypt/verify -H 'Content-Type: application/json' -d '{"password":"mypassword","hash":"HASH_HERE"}'`],
                    [:title = "Register + Login flow", :code = `curl -X POST http://localhost:3000/register -H 'Content-Type: application/json' -d '{"password":"secret123"}'
curl -X POST http://localhost:3000/login -H 'Content-Type: application/json' -d '{"password":"secret123"}'`]
                ]],
                [:title = "Encryption (AES-256-GCM)", :subsections = [
                    [:title = "Encrypt", :code = `curl -X POST http://localhost:3000/crypto/encrypt -H 'Content-Type: application/json' -d '{"plaintext":"secret data"}'`],
                    [:title = "Decrypt", :code = `curl -X POST http://localhost:3000/crypto/decrypt -H 'Content-Type: application/json' -d '{"ciphertext":"CIPHERTEXT_HERE"}'`]
                ]],
                [:title = "HMAC-SHA256", :subsections = [
                    [:title = "Sign", :code = `curl -X POST http://localhost:3000/crypto/hmac/sign -H 'Content-Type: application/json' -d '{"message":"hello","key":"my-key"}'`],
                    [:title = "Verify", :code = `curl -X POST http://localhost:3000/crypto/hmac/verify -H 'Content-Type: application/json' -d '{"message":"hello","key":"my-key","signature":"SIG_HERE"}'`]
                ]]
            ]
        ])
    })
}
