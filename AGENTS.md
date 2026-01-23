## Project structure

This is a Phoenix backend with a React SPA frontend. Phoenix serves as an API-only backend; React handles all UI rendering.

## Guidelines for dev tools

- Don't run the dev server. Assume the user is running it or will run it
manually.
- If the dev server needs to be restarted, tell the user, don't try to do it.

### Architecture overview

```
┌─────────────────────────────────────────────────────────────┐
│                        Browser                               │
│                    (React SPA)                              │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  localhost:3000 (Vite dev server)                   │   │
│  │  - HMR enabled                                      │   │
│  │  - Proxy: /api/* → localhost:4000                   │   │
│  │  - Proxy: /socket/* → ws://localhost:4000           │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
                              │
                              │ HTTP / WebSocket
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                   Phoenix (port 4000)                        │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  API Controllers                                    │   │
│  │  - FallbackController → serves SPA index.html      │   │
│  │  - REST endpoints under /api/*                     │   │
│  │                                                    │   │
│  │  Phoenix Channels (WebSocket)                      │   │
│  │  - UserSocket at /socket                           │   │
│  │  - RoomChannel for real-time features              │   │
│  │                                                    │   │
│  │  Ecto / SQLite                                     │   │
│  │  - Data persistence layer                          │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

### Directory structure

```
eatlog/
├── assets/                    # Frontend (Vite + React)
│   ├── index.html             # Root HTML template
│   ├── package.json           # npm dependencies (React, Vite, etc)
│   ├── vite.config.js         # Vite configuration
│   ├── src/
│   │   ├── main.jsx           # React entry point
│   │   ├── App.jsx            # Root React component
│   │   ├── index.css          # Tailwind imports + base styles
│   │   └── components/        # React components (add here)
│   ├── css/
│   │   └── app.css            # Tailwind directives only
│   ├── vendor/                # Third-party JS (daisyUI, heroicons)
│   └── public/                # Static assets (manifest.json)
│
├── lib/                       # Phoenix backend
│   ├── eat_log/
│   │   ├── application.ex     # OTP application config
│   │   ├── repo.ex            # Ecto.Repo (SQLite)
│   │   └── mailer.ex          # Swoosh mailer (unused)
│   │
│   └── eat_log_web/
│       ├── endpoint.ex        # Phoenix endpoint (HTTP/WebSocket)
│       ├── router.ex          # Route definitions
│       ├── telemetry.ex       # Telemetry setup
│       ├──.ex                 # Web module definition
│       │
│       ├── controllers/       # API controllers
│       │   ├── fallback_controller.ex  # SPA catch-all
│       │   ├── error_html.ex           # Error pages (unused)
│       │   └── error_json.ex            # JSON errors
│       │
│       ├── channels/          # Phoenix Channels
│       │   ├── user_socket.ex # Socket transport
│       │   └── room_channel.ex # Example channel
│       │
│       ├── plugs/             # Custom plugs
│       │   └── dev_redirect.ex # Dev-only redirect :4000 → :3000
│       │
│       └── components/        # Phoenix components (legacy)
│           ├── core_components.ex
│           └── layouts.ex
│
├── config/                    # Phoenix configuration
│   ├── config.exs            # Base config
│   ├── dev.exs               # Dev config (Vite watcher)
│   ├── prod.exs              # Production config
│   └── runtime.exs           # Runtime config (env vars)
│
├── priv/
│   ├── static/               # Built assets (gitignored)
│   │   ├── index.html        # Production SPA entry
│   │   ├── assets/           # Built JS/CSS bundles
│   │   └── manifest.json     # PWA manifest
│   │
│   └── repo/
│       ├── migrations/       # Ecto migrations
│       └── seeds.exs         # Database seeds
│
├── scripts/
│   └── dev                   # Dev server script (runs Vite + Phoenix)
│
└── test/                     # ExUnit tests
```

### Frontend details (assets/)

**Entry point chain:**

```
index.html
  └─→ src/main.jsx
       └─→ src/App.jsx
            └─→ src/components/* (your React components)
```

**Key files:**

- `src/main.jsx` - React 18 entry with `createRoot`
- `src/App.jsx` - Root component, imports all features
- `assets/css/app.css` - Tailwind v4 imports (minimal, mostly directives)
- `vite.config.js` - React plugin, PWA plugin, proxy config

**Dependencies:**

- React 18.3 (UI library)
- Vite 5.4 (build tool / dev server)
- Tailwind CSS 3.4 (styling)
- Phoenix 1.7 (WebSocket client for channels)

### Backend details (lib/)

**Request flow:**

```
HTTP Request → Endpoint → Router → Controller → JSON response
                                          ↓
                                    FallbackController
                                              ↓
                                    send_file("priv/static/index.html")
```

**Phoenix Channels (WebSocket):**

```
Browser → UserSocket.connect() → RoomChannel.join("room:lobby")
                                    ↓
                          broadcast/3 for real-time events
```

### Development workflow

```bash
# Start both servers (Vite on 3000, Phoenix on 4000)
./scripts/dev

# Or manually:
cd assets && pnpm dev    # localhost:3000 (HMR)
mix phx.server           # localhost:4000 (API + static files)
```

### Production build

```bash
cd assets && pnpm build  # Builds to priv/static/
mix phx.server           # Serves from priv/static/
```

### Key configuration files

| File | Purpose |
|------|---------|
| `assets/vite.config.js` | Vite plugins, proxy to Phoenix |
| `config/dev.exs` | Vite watcher for `mix phx.server` |
| `lib/eat_log_web/endpoint.ex` | HTTP/WebSocket serving |
| `lib/eat_log_web/router.ex` | Route definitions |
| `scripts/dev` | Combined dev server script |

## Project guidelines

- Use `mix precommit` alias when you are done with all changes and fix any pending issues
- Use the already included and available `:req` (`Req`) library for HTTP requests, **avoid** `:httpoison`, `:tesla`, and `:httpc`. Req is included by default and is the preferred HTTP client for Phoenix apps

### JS and CSS guidelines

- **Use Tailwind CSS classes and custom CSS rules** to create polished, responsive, and visually stunning interfaces.
- Tailwindcss v4 **no longer needs a tailwind.config.js** and uses a new import syntax in `app.css`:

      @import "tailwindcss" source(none);
      @source "../css";
      @source "../js";
      @source "../../lib/my_app_web";

- **Always use and maintain this import syntax** in the app.css file for projects generated with `phx.new`
- **Never** use `@apply` when writing raw css
- **Always** manually write your own tailwind-based components instead of using daisyUI for a unique, world-class design
- Out of the box **only the app.js and app.css bundles are supported**
  - You cannot reference an external vendor'd script `src` or link `href` in the layouts
  - You must import the vendor deps into app.js and app.css to use them
  - **Never write inline <script>custom js</script> tags within templates**

### UI/UX & design guidelines

- **Produce world-class UI designs** with a focus on usability, aesthetics, and modern design principles
- Implement **subtle micro-interactions** (e.g., button hover effects, and smooth transitions)
- Ensure **clean typography, spacing, and layout balance** for a refined, premium look
- Focus on **delightful details** like hover effects, loading states, and smooth page transitions

## Elixir guidelines

- Elixir lists **do not support index based access via the access syntax**

  **Never do this (invalid)**:

      i = 0
      mylist = ["blue", "green"]
      mylist[i]

  Instead, **always** use `Enum.at`, pattern matching, or `List` for index based list access, ie:

      i = 0
      mylist = ["blue", "green"]
      Enum.at(mylist, i)

- Elixir variables are immutable, but can be rebound, so for block expressions like `if`, `case`, `cond`, etc
  you *must* bind the result of the expression to a variable if you want to use it and you CANNOT rebind the result inside the expression, ie:

      # INVALID: we are rebinding inside the `if` and the result never gets assigned
      if connected?(socket) do
        socket = assign(socket, :val, val)
      end

      # VALID: we rebind the result of the `if` to a new variable
      socket =
        if connected?(socket) do
          assign(socket, :val, val)
        end

- **Never** nest multiple modules in the same file as it can cause cyclic dependencies and compilation errors
- **Never** use map access syntax (`changeset[:field]`) on structs as they do not implement the Access behaviour by default. For regular structs, you **must** access the fields directly, such as `my_struct.field` or use higher level APIs that are available on the struct if they exist, `Ecto.Changeset.get_field/2` for changesets
- Elixir's standard library has everything necessary for date and time manipulation. Familiarize yourself with the common `Time`, `Date`, `DateTime`, and `Calendar` interfaces by accessing their documentation as necessary. **Never** install additional dependencies unless asked or for date/time parsing (which you can use the `date_time_parser` package)
- Don't use `String.to_atom/1` on user input (memory leak risk)
- Predicate function names should not start with `is_` and should end in a question mark. Names like `is_thing` should be reserved for guards
- Elixir's builtin OTP primitives like `DynamicSupervisor` and `Registry`, require names in the child spec, such as `{DynamicSupervisor, name: MyApp.MyDynamicSup}`, then you can use `DynamicSupervisor.start_child(MyApp.MyDynamicSup, child_spec)`
- Use `Task.async_stream(collection, callback, options)` for concurrent enumeration with back-pressure. The majority of times you will want to pass `timeout: :infinity` as option

## Mix guidelines

- Read the docs and options before using tasks (by using `mix help task_name`)
- To debug test failures, run tests in a specific file with `mix test test/my_test.exs` or run all previously failed tests with `mix test --failed`
- `mix deps.clean --all` is **almost never needed**. **Avoid** using it unless you have good reason

## Test guidelines

- **Always use `start_supervised!/1`** to start processes in tests as it guarantees cleanup between tests
- **Avoid** `Process.sleep/1` and `Process.alive?/1` in tests
  - Instead of sleeping to wait for a process to finish, **always** use `Process.monitor/1` and assert on the DOWN message:

      ref = Process.monitor(pid)
       assert_receive {:DOWN, ^ref, :process, ^pid, :normal}

    - Instead of sleeping to synchronize before the next call, **always** use `_ = :sys.get_state/1` to ensure the process has handled prior messages

## Phoenix guidelines

- Remember Phoenix router `scope` blocks include an optional alias which is prefixed for all routes within the scope. **Always** be mindful of this when creating routes within a scope to avoid duplicate module prefixes.

- You **never** need to create your own `alias` for route definitions! The `scope` provides the alias, ie:

      scope "/admin", AppWeb.Admin do
        pipe_through :browser

        get "/users", UserController, :index
      end

  the UserController route would point to the `AppWeb.Admin.UserController` module

- `Phoenix.View` no longer is needed or included with Phoenix, don't use it

## Ecto Guidelines

- **Always** preload Ecto associations in queries when they'll be accessed in templates, ie a message that needs to reference the `message.user.email`
- Remember `import Ecto.Query` and other supporting modules when you write `seeds.exs`
- `Ecto.Schema` fields always use the `:string` type, even for `:text`, columns, ie: `field :name, :string`
- `Ecto.Changeset.validate_number/2` **DOES NOT SUPPORT the `:allow_nil` option**. By default, Ecto validations only run if a change for the given field exists and the change value is not nil, so such as option is never needed
- You **must** use `Ecto.Changeset.get_field(changeset, :field)` to access changeset fields
- Fields which are set programatically, such as `user_id`, must not be listed in `cast` calls or similar for security purposes. Instead they must be explicitly set when creating the struct
- **Always** invoke `mix ecto.gen.migration migration_name_using_underscores` when generating migration files, so the correct timestamp and conventions are applied
