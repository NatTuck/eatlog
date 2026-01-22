# Vite Migration Plan for Phoenix + React SPA + PWA

## Overview
Replace the current esbuild/tailwind setup with Vite for building a React-based progressive web app (PWA) with Phoenix backend. Key requirements:
- Use JS (not TypeScript/TSX)
- Use pnpm for package management
- Pure React SPA (remove all LiveView references)
- Phoenix serves single root HTML document
- Use Phoenix channels for server interaction
- PWA focus: offline support

## Current Setup Analysis
- **Build Tools**: esbuild (v0.25.4) for JS bundling, Tailwind CSS (v4.1.12) for styling via Mix dependencies
- **Assets Structure**: `assets/js/app.js` (Phoenix LiveView), `assets/css/app.css` (Tailwind), `assets/vendor/` (static files)
- **Integration**: Configured in `mix.exs` aliases and `config/config.exs`; no `package.json`

## Dependencies
**Frontend (assets/package.json):**
- `react`: ^18.3.1
- `react-dom`: ^18.3.1
- `vite`: ^5.4.8
- `phoenix`: ^1.7.14 (channels client)
- `vite-plugin-pwa`: ^0.20.5
- `workbox-window`: ^7.1.0

**Backend:** Phoenix channels (built-in), no additional deps

**Package Manager:** pnpm

## File Structure
```
your_app/
├── assets/                    # Vite frontend
│   ├── public/
│   │   ├── index.html         # Single root HTML served by Phoenix
│   │   ├── manifest.json      # PWA manifest
│   │   └── icons/             # PWA icons (192x192, 512x512)
│   ├── src/
│   │   ├── main.js            # React entry point
│   │   ├── App.js             # Main React component
│   │   ├── components/        # React components
│   │   ├── hooks/
│   │   │   └── useChannel.js  # Custom hook for Phoenix channels
│   │   ├── services/          # API and channel services
│   │   └── utils/             # Utilities (e.g., offline detection)
│   ├── package.json           # pnpm dependencies
│   └── vite.config.js         # Vite config with PWA plugin
├── lib/your_app_web/
│   ├── channels/              # Phoenix channels (UserSocket, RoomChannel)
│   ├── controllers/           # API controllers + PageController for SPA
│   └── router.ex              # Updated with catch-all routes
├── priv/static/               # Built assets output
└── config/dev.exs             # Updated watcher for Vite
```

## Configuration Files

### Vite Config (assets/vite.config.js)
```js
import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';
import { VitePWA } from 'vite-plugin-pwa';

export default defineConfig({
  plugins: [
    react(),
    VitePWA({
      registerType: 'autoUpdate',
      workbox: {
        globPatterns: ['**/*.{js,css,html,ico,png,svg}'],
        runtimeCaching: [
          {
            urlPattern: /^https:\/\/api\.yourapp\.com\/.*/i,
            handler: 'NetworkFirst',
            options: {
              cacheName: 'api-cache',
              expiration: {
                maxEntries: 100,
                maxAgeSeconds: 60 * 60 * 24 * 365, // 1 year
              },
            },
          },
        ],
      },
      manifest: {
        name: 'Your App Name',
        short_name: 'App',
        description: 'Your app description',
        theme_color: '#ffffff',
        icons: [
          {
            src: 'icon-192x192.png',
            sizes: '192x192',
            type: 'image/png',
          },
          {
            src: 'icon-512x512.png',
            sizes: '512x512',
            type: 'image/png',
          },
        ],
      },
    }),
  ],
  build: {
    outDir: '../priv/static',
    emptyOutDir: true,
  },
  server: {
    port: 3000,
    host: 'localhost',
  },
});
```

### Phoenix Dev Config (config/dev.exs)
```elixir
config :your_app, YourAppWeb.Endpoint,
  # ... other config
  watchers: [
    node: [
      "node_modules/.bin/vite",
      "build",
      "--mode",
      "development",
      cd: Path.expand("../assets", __DIR__)
    ]
  ],
  live_reload: [
    patterns: [
      ~r"priv/static/.*(js|css|png|jpeg|jpg|gif|svg)$",
      ~r"lib/your_app_web/(live|views)/.*(ex)$",
      ~r"lib/your_app_web/templates/.*(eex)$"
    ]
  ]
```

### Phoenix Router (lib/your_app_web/router.ex)
```elixir
defmodule YourAppWeb.Router do
  use YourAppWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", YourAppWeb do
    pipe_through :api

    # API routes for data
    get "/api/data", DataController, :index
    post "/api/data", DataController, :create

    # Serve React SPA
    get "/", PageController, :index
    get "/*path", PageController, :index  # Catch-all for SPA routing
  end

  # Enable Phoenix channels
  socket "/socket", YourAppWeb.UserSocket,
    websocket: true,
    longpoll: false
end
```

### Page Controller (lib/your_app_web/controllers/page_controller.ex)
```elixir
defmodule YourAppWeb.PageController do
  use YourAppWeb, :controller

  def index(conn, _params) do
    conn
    |> put_resp_header("content-type", "text/html")
    |> send_file(200, "priv/static/index.html")
  end
end
```

### User Socket (lib/your_app_web/channels/user_socket.ex)
```elixir
defmodule YourAppWeb.UserSocket do
  use Phoenix.Socket

  channel "room:*", YourAppWeb.RoomChannel

  @impl true
  def connect(_params, socket, _connect_info) do
    {:ok, socket}
  end

  @impl true
  def id(_socket), do: nil
end
```

### Room Channel (lib/your_app_web/channels/room_channel.ex)
```elixir
defmodule YourAppWeb.RoomChannel do
  use Phoenix.Channel

  @impl true
  def join("room:lobby", _payload, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_in("new_msg", %{"body" => body}, socket) do
    broadcast!(socket, "new_msg", %{body: body})
    {:noreply, socket}
  end
end
```

## Implementation Steps

1. **Set Up Vite with React and pnpm:**
   - Create `assets/` directory
   - Run `pnpm create vite . --template react` in `assets/`
   - Update `package.json` to use pnpm scripts
   - Install dependencies: `pnpm add react react-dom phoenix vite-plugin-pwa workbox-window`

2. **Configure Phoenix to serve single HTML document:**
   - Update router to catch-all routes to `PageController`
   - Create `PageController` to serve `priv/static/index.html`
   - Ensure `index.html` includes `<div id="root"></div>` for React mounting

3. **Integrate Phoenix Channels in React:**
   - In `src/main.js`, import and connect Phoenix socket:
     ```js
     import { Socket } from 'phoenix';
     const socket = new Socket('/socket/websocket');
     socket.connect();
     ```
   - Create `useChannel.js` hook:
     ```js
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
   - Use in components: `const { push } = useChannel('room:lobby', handleMessage);`

4. **Implement PWA Offline Support:**
   - Configure `vite-plugin-pwa` in `vite.config.js` for precaching and runtime caching
   - Add offline detection in React:
     ```js
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
   - Cache API responses using Workbox in service worker
   - Show offline UI when network fails

5. **Build and Deployment:**
   - Run `pnpm build` in assets to generate production build
   - Phoenix serves static files from `priv/static`
   - For production, ensure channels are properly configured

## Challenges & Solutions

**Channel Integration Challenges:**
- **Real-time vs. Offline Conflict:** Phoenix channels require WebSocket connection, which fails offline. Need to implement offline queuing (store messages locally, sync when online).
- **Authentication:** Channels may need user authentication; React SPA needs to pass auth tokens in socket params.
- **State Synchronization:** React state must sync with channel broadcasts; offline changes need reconciliation when reconnecting.
- **Error Handling:** Handle connection drops, reconnections, and message delivery failures gracefully.

**Offline PWA Challenges:**
- **Channel Offline Behavior:** Decide whether to disable real-time features offline or queue actions for later sync.
- **Data Consistency:** Ensure cached data doesn't conflict with server state when reconnecting.
- **Service Worker Scope:** Ensure SW doesn't interfere with Phoenix's static file serving.
- **Cache Invalidation:** Implement proper cache-busting for API responses and assets.
- **Background Sync:** Use Service Worker background sync for queued channel messages when online.
- **Storage Limits:** Respect browser storage quotas for cached data.

## Commands
- **Dev:** `mix phx.server` (runs Phoenix + Vite via watchers)
- **Prod:** `MIX_ENV=prod mix do compile, assets.build, phx.server`