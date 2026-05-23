# Environment Variables - Env class
# Run: ring 19_env.ring
# A .env file will be auto-created if missing.

load "bolt.ring"

# Create .env if it does not exist
if !fexists(".env")
    cEnvFile = "DATABASE_URL=postgres://localhost/mydb" + char(10)
    cEnvFile += "SECRET=my-secret-key" + char(10)
    cEnvFile += "PORT=3000" + char(10)
    cEnvFile += "APP_ENV=development" + char(10)
    write(".env", cEnvFile)
ok

env = new Env()

new Bolt() {
    port = 3000

    # Get environment variables
    @get("/env/:key", func {
        cKey = $bolt.param("key")
        cValue = env.getVar(cKey)

        if cValue = ""
            $bolt.jsonWithStatus(404, [:error = "Variable not found", :key = cKey])
        else
            $bolt.json([:key = cKey, :value = cValue])
        ok
    })

    # Get with default fallback
    @get("/env/:key/:default", func {
        cKey = $bolt.param("key")
        cDefault = $bolt.param("default")
        cValue = env.getOr(cKey, cDefault)

        $bolt.json([:key = cKey, :value = cValue, :default = cDefault])
    })

    # Set environment variable (before server starts)
    # Note: setVar works before server start; after start, use loadFile or reload
    @post("/env", func {
        data = $bolt.jsonBody()
        $bolt.json([:note = "Use loadFile or reload endpoints to update env vars at runtime", :key = data[:key], :value = data[:value]])
    })

    # Load from custom file path
    @post("/env/load", func {
        data = $bolt.jsonBody()
        env.loadFile(data[:path])
        $bolt.json([:loaded = true, :path = data[:path]])
    })

    # Reload .env
    @post("/env/reload", func {
        env.loadEnv()
        $bolt.json([:reloaded = true])
    })

    # Use env for server config
    @get("/config", func {
        $bolt.json([
            :database_url = env.getOr("DATABASE_URL", "postgres://localhost/default"),
            :app_env = env.getOr("APP_ENV", "development"),
            :secret_set = env.getVar("SECRET") != "",
            :port = env.getOr("PORT", "3000")
        ])
    })

    @get("/", func {
        $bolt.html(`
<h1>Environment Variables Example</h1>
<p>Create a <code>.env</code> file in the current directory:</p>
<pre>DATABASE_URL=postgres://localhost/mydb
SECRET=my-secret-key
PORT=3000
APP_ENV=development</pre>

<h3>Try these:</h3>
<pre>
# Get env variable
curl http://localhost:3000/env/DATABASE_URL

# Get with default fallback
curl http://localhost:3000/env/MISSING_KEY/fallback_value

# Set env variable
curl -X POST http://localhost:3000/env \
  -H 'Content-Type: application/json' \
  -d '{"key":"MY_VAR","value":"hello"}'

# View config
curl http://localhost:3000/config

# Reload .env
curl -X POST http://localhost:3000/env/reload

# Load from custom file
curl -X POST http://localhost:3000/env/load \
  -H 'Content-Type: application/json' \
  -d '{"path":"/path/to/.env"}'
</pre>
        `)
    })
}
