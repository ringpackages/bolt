# DateTime & Utility Methods - Timestamps, formatting, UUID, URL encoding
# Run: ring 31_datetime.ring

load "bolt.ring"

dt = new DateTime

new Bolt() {
    port = 3000

    # Current time in various formats
    @get("/now", func {
        $bolt.json([
            :local = dt.now(),
            :utc = dt.nowUtc(),
            :timestamp = dt.timestamp(),
            :timestamp_ms = dt.timestampMs()
        ])
    })

    # Format a timestamp
    @get("/format", func {
        nTs = dt.timestamp()
        $bolt.json([
            :iso = dt.formatDate(nTs, "%Y-%m-%dT%H:%M:%S"),
            :friendly = dt.formatDate(nTs, "%B %d, %Y"),
            :date_only = dt.formatDate(nTs, "%Y-%m-%d"),
            :time_only = dt.formatDate(nTs, "%H:%M:%S"),
            :custom = dt.formatDate(nTs, "%A, %B %d, %Y at %I:%M %p"),
            :rfc2822 = dt.formatDate(nTs, "%a, %d %b %Y %H:%M:%S")
        ])
    })

    # Parse a date string to timestamp
    @get("/parse/:date", func {
        cDate = $bolt.param("date")
        nTs = dt.parseDate(cDate + " 00:00:00", "%Y-%m-%d %H:%M:%S")
        if nTs > 0
            $bolt.json([
                :input = cDate,
                :timestamp = nTs,
                :formatted = dt.formatDate(nTs, "%A, %B %d, %Y")
            ])
        else
            $bolt.jsonWithStatus(400, [:error = "Invalid date format", :input = cDate])
        ok
    })

    # Date arithmetic
    @get("/arithmetic", func {
        nTs = dt.timestamp()
        $bolt.json([
            :now = dt.formatDate(nTs, "%Y-%m-%d %H:%M:%S"),
            :plus_7_days = dt.formatDate(dt.addDays(nTs, 7), "%Y-%m-%d %H:%M:%S"),
            :minus_3_days = dt.formatDate(dt.addDays(nTs, -3), "%Y-%m-%d %H:%M:%S"),
            :plus_24_hours = dt.formatDate(dt.addHours(nTs, 24), "%Y-%m-%d %H:%M:%S"),
            :plus_1_hour = dt.formatDate(dt.addHours(nTs, 1), "%Y-%m-%d %H:%M:%S")
        ])
    })

    # Difference between two dates
    @get("/diff/:ts1/:ts2", func {
        nTs1 = 0 + $bolt.param("ts1")
        nTs2 = 0 + $bolt.param("ts2")
        nDiff = dt.diff(nTs1, nTs2)

        $bolt.json([
            :timestamp1 = nTs1,
            :timestamp2 = nTs2,
            :diff_seconds = nDiff,
            :diff_minutes = nDiff / 60,
            :diff_hours = nDiff / 3600,
            :diff_days = nDiff / 86400
        ])
    })

    # Expiry calculator
    @get("/expires/:days", func {
        nDays = 0 + $bolt.param("days")
        nTs = dt.timestamp()
        nExpiry = dt.addDays(nTs, nDays)

        $bolt.json([
            :now = dt.formatDate(nTs, "%Y-%m-%d"),
            :expires = dt.formatDate(nExpiry, "%Y-%m-%d"),
            :days = nDays,
            :seconds_until = dt.diff(nExpiry, nTs)
        ])
    })

    # Server uptime using unixtime utilities
    @get("/time", func {
        $bolt.json([
            :unix_seconds = $bolt.unixtime(),
            :unix_milliseconds = $bolt.unixtimeMs(),
            :uuid = $bolt.uuid(),
            :url_encoded = $bolt.urlEncode("hello world & foo=bar"),
            :url_decoded = $bolt.urlDecode("hello%20world%20%26%20foo%3Dbar")
        ])
    })

    @get("/", func {
        $bolt.renderFile("./templates/layout.html", [
            :title = "Bolt - DateTime",
            :subtitle = "Timestamp operations, formatting, and arithmetic",
            :sections = [
                [:title = "Endpoints", :subsections = [
                    [:title = "Current time", :code = "curl http://localhost:3000/now"],
                    [:title = "Formatted dates", :code = "curl http://localhost:3000/format"],
                    [:title = "Parse a date", :code = "curl http://localhost:3000/parse/2026-05-03"],
                    [:title = "Date arithmetic", :code = "curl http://localhost:3000/arithmetic"],
                    [:title = "Difference between timestamps", :code = "curl http://localhost:3000/diff/1706889600/1706976000"],
                    [:title = "Expiry calculator", :code = "curl http://localhost:3000/expires/30"],
                    [:title = "Unix time + UUID + URL encode/decode", :code = "curl http://localhost:3000/time"]
                ]]
            ]
        ])
    })
}
