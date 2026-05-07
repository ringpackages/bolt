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
