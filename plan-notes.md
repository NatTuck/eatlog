# Vite Migration Plan - Additional Notes

This file contains information not covered in AGENTS.md.

## Phoenix Channels Hook

```jsx
import { useEffect, useState } from 'react';

export function useChannel(topic, onMessage) {
  const [channel, setChannel] = useState(null);
  const [isJoined, setIsJoined] = useState(false);

  useEffect(() => {
    const socket = new Socket('/socket/websocket');
    socket.connect();

    const chan = socket.channel(topic);
    chan.join()
      .receive('ok', () => setIsJoined(true))
      .receive('error', (err) => console.error('Failed to join', err));

    chan.onMessage = (event, payload) => {
      if (onMessage) onMessage(event, payload);
      return payload;
    };

    setChannel(chan);

    return () => chan.leave();
  }, [topic, onMessage]);

  const push = (event, payload) => {
    if (channel && isJoined) {
      channel.push(event, payload);
    }
  };

  return { channel, isJoined, push };
}
```

## Offline Detection Hook

```jsx
import { useState, useEffect } from 'react';

function useOffline() {
  const [isOffline, setIsOffline] = useState(!navigator.onLine);

  useEffect(() => {
    const handleOnline = () => setIsOffline(false);
    const handleOffline = () => setIsOffline(true);

    window.addEventListener('online', handleOnline);
    window.addEventListener('offline', handleOffline);

    return () => {
      window.removeEventListener('online', handleOnline);
      window.removeEventListener('offline', handleOffline);
    };
  }, []);

  return isOffline;
}
```

## Architectural Challenges

### Phoenix Channels + Offline

- **Real-time vs. Offline Conflict:** Phoenix channels require WebSocket connection, which fails offline. Consider offline queuing (store messages locally, sync when online).
- **Authentication:** Channels may need user authentication; React SPA passes auth tokens in socket params.
- **State Synchronization:** React state must sync with channel broadcasts; offline changes need reconciliation when reconnecting.
- **Error Handling:** Handle connection drops, reconnections, and message delivery failures gracefully.

### PWA Offline Support

- **Channel Offline Behavior:** Decide whether to disable real-time features offline or queue actions for later sync.
- **Data Consistency:** Ensure cached data doesn't conflict with server state when reconnecting.
- **Service Worker Scope:** Ensure SW doesn't interfere with Phoenix's static file serving.
- **Cache Invalidation:** Implement proper cache-busting for API responses and assets.
- **Background Sync:** Use Service Worker background sync for queued channel messages when online.
- **Storage Limits:** Respect browser storage quotas for cached data.

## Known Issues

- Test `test/eat_log_web/controllers/page_controller_test.exs` fails - PageController was removed, test needs to be removed or updated
