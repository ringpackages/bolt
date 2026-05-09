---
title: "Server-Sent Events"
weight: 15
summary: "SSE endpoints for server-push streaming to clients"
---

### @sse(cPath)
Register SSE endpoint for clients to subscribe.

```ring
@sse("/events")
```

### $bolt.sseFilterParams(cPath)
Enable param-based event filtering for an SSE route. When enabled, subscribers will only receive events whose params are a superset of their own route params. Must be called after `@sse`.

```ring
@sse("/channel/:name")
sseFilterParams("/channel/:name")
```

With filtering enabled, a subscriber on `/channel/sports` will only receive broadcasts where the params include `name: "sports"`. Without filtering, all subscribers on the channel receive all events.

### $bolt.sseMaxSubscribers(nMax)
Set the maximum concurrent SSE subscribers per route. When the limit is reached, new subscribers receive a 503 response with a `Retry-After` header. Default: 1000.

```ring
sseMaxSubscribers(500)
```

### $bolt.sseBroadcast(cPath, cData)
Send data event to all subscribers.

```ring
$bolt.sseBroadcast("/events", "New notification!")
```

### $bolt.sseBroadcastEvent(cPath, cEventName, cData)
Send named event to all subscribers.

```ring
$bolt.sseBroadcastEvent("/events", "update", "v2 released")
```

### $bolt.sseBroadcastParams(cPath, cData, aParams)
Send data event to subscribers matching a params filter. Only subscribers whose route params contain all the specified key-value pairs will receive the event.

```ring
$bolt.sseBroadcastParams("/sse/channel/:name", "goal!", [:name = "sports"])
```

Subscribers on `/sse/channel/sports` receive the event; subscribers on `/sse/channel/tech` do not.

### $bolt.sseBroadcastEventParams(cPath, cEventName, cData, aParams)
Send named event to subscribers matching a params filter.

```ring
$bolt.sseBroadcastEventParams("/sse/channel/:name", "breaking", "headline", [:name = "news"])
```

**Client-side:**
```javascript
const es = new EventSource('/events');
es.onmessage = (e) => console.log(e.data);
es.addEventListener('update', (e) => console.log(e.data));
```
