# Guild Board

An AI-powered Kanban board where human developers and AI coding agents collaborate on the same project board. Built as a Rails 8.1 production boilerplate with a "Built-in First" philosophy — maximizing Rails 8 native capabilities with minimal external dependencies.

```
Human developers and AI agents work together on the same board.
Agents create tasks, post comments, move cards, and update checklists
via the MCP server. Humans see every change in real time via Action Cable.
```

---

## Table of Contents

- [A. Technology Stack](#a-technology-stack)
- [B. Key Features](#b-key-features)
- [C. Local Development Setup](#c-local-development-setup)
- [D. MCP — AI Agent Integration](#d-mcp--ai-agent-integration)
- [E. Testing](#e-testing)
- [F. Deployment (Kamal 2)](#f-deployment-kamal-2)
- [G. Directory Structure](#g-directory-structure)

---

## A. Technology Stack

### Built-in First Philosophy

Every architectural choice maximizes Rails 8 native capabilities. Only 5 external gems are added beyond Rails defaults. There is no Node.js, no webpack, and no build step.

**External gems:** pundit, pagy, lograge, view_component, fast-mcp

### Stack

| Layer | Choice | Version |
|---|---|---|
| Ruby | MRI | ~> 3.4 |
| Rails | Full-stack | ~> 8.1 |
| Database | PostgreSQL | 17.x |
| Frontend | Hotwire (Turbo + Stimulus) | turbo-rails ~> 2.0 |
| CSS | Tailwind CSS v4 | tailwindcss-rails ~> 4.2 |
| Asset Pipeline | Propshaft + Import Maps | propshaft ~> 1.1 |
| Drag and Drop | SortableJS | via CDN (Import Maps) |
| Real-time | Action Cable + SolidCable | built-in |
| Background Jobs | SolidQueue | ~> 1.3 |
| Caching | SolidCache | ~> 1.0 |
| Auth | Rails 8 built-in | bcrypt ~> 3.1 |
| Authorization | Pundit | ~> 2.5 |
| Pagination | Pagy | ~> 43.0 |
| UI Components | ViewComponent | ~> 4.4 |
| AI Integration | fast-mcp | via MCP protocol |
| Deployment | Kamal 2 | ~> 2.10 |

### Multi-Database Setup

Single PostgreSQL server with 4 logical databases:

| Connection | Purpose | Migrations |
|---|---|---|
| `primary` | Application data | `db/migrate/` |
| `cache` | SolidCache | `db/cache_migrate/` |
| `queue` | SolidQueue | `db/queue_migrate/` |
| `cable` | SolidCable | `db/cable_migrate/` |

No Redis required. The Solid Stack handles caching, jobs, and WebSockets entirely on PostgreSQL.

---

## B. Key Features

### Kanban Board with Drag and Drop

- Board columns with ordered tasks (Backlog, Todo, In Progress, Review, Done created automatically per project)
- Drag-and-drop reordering via SortableJS — no Node.js build required
- Real-time board updates via Action Cable and Turbo Streams — changes from any client (human or AI agent) appear instantly for all viewers

### Task Management

- Priority levels (low, medium, high)
- Labels with custom colors, scoped per project
- Checklists with ordered items and completion tracking
- Comments from both human users and AI agents
- Soft delete with restore support

### MCP Server for AI Agent Integration

- Built-in MCP (Model Context Protocol) server via fast-mcp, mounted at `/mcp`
- Per-project API keys with BCrypt digest storage and rate limiting (60 requests/minute)
- AI agents authenticate with `X-Project-Key` header and identify themselves with `X-Agent-Name`
- Available tools: `list_columns`, `list_tasks`, `get_task`, `create_task`, `update_task`, `move_task`, `add_comment`, `update_checklist`
- Agent actions are recorded in the activity log alongside human actions

### Activity Timeline

- Append-only audit log per project (read-only after creation)
- Records who did what and when — human user or named AI agent
- Rendered as a timeline on the task detail page

### Role-Based Access Control

- User roles: `user`, `admin`, `super_admin`
- Pundit policies with a default-deny `ApplicationPolicy`
- Admin namespace with separate Modern UI design

### Dual Design System

- **User-facing pages:** Neo-Brutalism — hard shadows, thick borders, flat colors
- **Admin pages:** Modern UI — rounded corners, soft shadows, indigo palette

---

## C. Local Development Setup

### Prerequisites

- Ruby 3.4 or later (rbenv, asdf, or mise)
- Docker (for PostgreSQL 17 only — Rails runs natively)
- Bundler 2.x

### Setup

```bash
# Step 1: Start PostgreSQL 17 via Docker
docker-compose up db -d

# Step 2: Install dependencies, create databases, run migrations, seed data
bin/setup

# Step 3: Start the development server
bin/dev
```

`bin/dev` uses Foreman to run three processes in parallel via `Procfile.dev`:

| Process | Description |
|---|---|
| `web` | Rails application server (port 3100) |
| `css` | Tailwind CSS v4 watcher |
| `jobs` | SolidQueue worker |

### Seed Data

| File | Environment | Description |
|---|---|---|
| `db/seeds/admin_user.rb` | All environments | Creates the initial super_admin user |
| `db/seeds/sample_data.rb` | Development only | Creates 10 sample regular users |
| `db/seeds/projects.rb` | Development only | Creates 2 sample projects with tasks |

The admin user credentials are controlled by environment variables:

```bash
ADMIN_EMAIL=admin@example.com   # default
ADMIN_PASSWORD=password123      # default — change in production
```

### Common Commands

```bash
bin/rails db:migrate     # Run pending migrations
bin/rails db:seed        # Re-run seed files
bin/rubocop              # Lint (rubocop-rails-omakase)
bin/brakeman             # Static security analysis
bin/bundler-audit        # Gem vulnerability audit
bin/importmap audit      # JS dependency audit
bin/ci                   # Full CI suite: lint + security + tests
```

---

## D. MCP — AI Agent Integration

Guild Board exposes an MCP (Model Context Protocol) server that lets AI coding agents (Claude, Cursor, etc.) interact with the Kanban board programmatically.

### How It Works

```
AI Agent (Claude, Cursor, etc.)
  └── MCP client
        └── SSE /mcp/sse  (with X-Project-Key header)
              └── Guild Board MCP server
                    └── Tool execution (create_task, move_task, ...)
                          └── Board updates broadcast to all viewers via Action Cable
```

### Creating a Project API Key

1. Open your project in Guild Board
2. Navigate to **Settings > API Keys**
3. Click **Generate New Key** — the raw key is shown once, copy it immediately
4. The key is stored as a BCrypt digest; only the prefix is stored in plaintext for lookup

### Connecting an AI Agent

Configure your MCP client with the following settings. The MCP server supports both **SSE** and **Streamable HTTP** transports:

| Transport | Endpoint | MCP Protocol Version |
|---|---|---|
| SSE | `/mcp/sse` | 2024-11-05 |
| Streamable HTTP | `/mcp/messages` | 2025-03-26 |

**Production:**

```json
{
  "mcpServers": {
    "guild-board": {
      "type": "sse",
      "url": "https://your-domain.com/mcp/sse",
      "headers": {
        "X-Project-Key": "guild_your_raw_project_key_here",
        "X-Agent-Name": "claude-code"
      }
    }
  }
}
```

**Local development** (the MCP server is `localhost_only` in non-production environments):

```json
{
  "mcpServers": {
    "guild-board": {
      "type": "sse",
      "url": "http://localhost:3100/mcp/sse",
      "headers": {
        "X-Project-Key": "guild_your_raw_project_key_here",
        "X-Agent-Name": "claude-code"
      }
    }
  }
}
```

> Claude Code uses `type: "sse"`. Other MCP clients may use `streamable-http` with the `/mcp/messages` endpoint — check your client's documentation.

### Available MCP Tools

| Tool | Description |
|---|---|
| `list_columns` | List all board columns with task counts |
| `list_tasks` | List tasks in a column with filtering |
| `get_task` | Get full task details including checklists and comments |
| `create_task` | Create a new task in a specified column |
| `update_task` | Update task title, description, or priority |
| `move_task` | Move a task to a different column |
| `add_comment` | Post a comment on a task |
| `update_checklist` | Mark a checklist item complete or incomplete |

### Rate Limiting

Each project key is rate-limited to **60 requests per minute**. Requests that exceed the limit receive an authentication failure response.

### Production Configuration

Set these secrets in `.kamal/secrets` before deploying:

```bash
MCP_ALLOWED_ORIGIN=https://your-domain.com
APP_DOMAIN=your-domain.com
```

The MCP server uses `MCP_ALLOWED_ORIGIN` to restrict cross-origin requests in production. In development and test environments, `localhost_only` mode is enabled automatically.

---

## E. Testing

Minitest with parallel execution. System tests use Capybara and headless Chrome.

### Running Tests

```bash
# All unit and integration tests
bin/rails test

# System tests (Capybara + headless Chrome)
bin/rails test:system

# Single test file
bin/rails test test/models/user_test.rb

# Single test by line number
bin/rails test test/models/user_test.rb:42

# Full CI suite (lint + security + tests)
bin/ci
```

> If the pg gem segfaults with parallel workers, use `PARALLEL_WORKERS=1 bin/rails test`.

### Test Organization

| Directory | Contents |
|---|---|
| `test/models/` | Model unit tests |
| `test/policies/` | Pundit policy tests |
| `test/components/` | ViewComponent tests |
| `test/controllers/` | Controller integration tests |
| `test/tools/` | MCP tool tests |
| `test/jobs/` | Background job tests |
| `test/system/` | End-to-end browser tests (Capybara) |

### Test Helpers

- `sign_in_as(user)` and `sign_out` are available in all `ActionDispatch::IntegrationTest` subclasses via `test/test_helpers/session_test_helper.rb`
- Fixtures in `test/fixtures/` — key users: `regular` (user role), `admin`, `super_admin`

---

## F. Deployment (Kamal 2)

### Proxy Architecture

```
[Internet] → [kamal-proxy] → [Thruster] → [Puma]
               SSL/HTTP2       gzip           Rails app
               routing         asset caching
               error pages     X-Sendfile
```

### Configuration Files

| File | Purpose |
|---|---|
| `config/deploy.yml` | Main Kamal deployment configuration |
| `.kamal/secrets` | Runtime secrets (gitignored) |
| `.kamal/hooks/pre-deploy` | Pre-deployment checks |

### Required Secrets

Before deploying, set all values in `.kamal/secrets`:

| Secret | Description |
|---|---|
| `KAMAL_REGISTRY_PASSWORD` | Container registry credentials |
| `RAILS_MASTER_KEY` | Rails credentials decryption key |
| `DATABASE_URL` | PostgreSQL connection string |
| `MCP_ALLOWED_ORIGIN` | Allowed origin for MCP cross-origin requests |
| `APP_DOMAIN` | Your application domain |

### Deployment Commands

```bash
# First-time server setup
kamal setup

# Deploy a new release
kamal deploy

# Stream application logs
kamal app logs

# Open a Rails console on the remote server
kamal app exec --interactive --reuse "bin/rails console"

# Roll back to the previous release
kamal rollback
```

### Health Checks

| Endpoint | Type | Description |
|---|---|---|
| `/up` | Liveness | Rails built-in; returns 200 when the process is running |
| `/health` | Readiness | Performs a database connectivity check |

### SSL (Let's Encrypt)

SSL is commented out in `config/deploy.yml`. To enable it:

1. Confirm DNS A record points to the server IP
2. Open ports 80 and 443
3. Uncomment in `config/deploy.yml`:

```yaml
proxy:
  host: yourdomain.com
  ssl: true
  ssl_redirect: true
  forward_headers: true
```

> `forward_headers: true` is required when SSL is enabled. Without it, `request.ssl?` returns false inside Rails, and secure cookie flags are not set.

---

## G. Directory Structure

```
guild-board/
├── app/
│   ├── channels/                    # Action Cable channels (BoardChannel)
│   ├── components/                  # ViewComponent (14 components)
│   ├── controllers/
│   │   ├── admin/                   # Admin namespace (role-checked)
│   │   ├── concerns/
│   │   │   ├── authentication.rb    # Rails 8 auth helpers
│   │   │   └── activity_loggable.rb # Audit log concern
│   │   └── ...
│   ├── javascript/
│   │   └── controllers/             # Stimulus controllers
│   │       ├── drag_controller.js   # SortableJS kanban
│   │       ├── filter_controller.js # Board filtering
│   │       └── frame_modal_controller.js
│   ├── jobs/                        # Active Job (SolidQueue)
│   ├── models/
│   │   ├── concerns/
│   │   │   └── positionable.rb      # Reusable ordering concern
│   │   ├── current.rb               # CurrentAttributes (user, project, agent_name)
│   │   └── ...
│   ├── policies/                    # Pundit authorization policies
│   ├── tools/                       # MCP tools (fast-mcp)
│   │   ├── application_tool.rb
│   │   ├── concerns/
│   │   │   └── mcp_authentication.rb
│   │   └── ...
│   └── views/
│       ├── layouts/
│       │   ├── application.html.erb # User-facing (Neo-Brutalism)
│       │   └── admin.html.erb       # Admin (Modern UI)
│       └── ...
├── config/
│   ├── database.yml                 # Multi-DB (primary/cache/queue/cable)
│   ├── deploy.yml                   # Kamal 2 deployment config
│   ├── importmap.rb                 # Import Maps (SortableJS pinned to CDN)
│   └── initializers/
│       ├── fast_mcp.rb              # MCP server configuration
│       ├── pagy.rb
│       └── lograge.rb
├── db/
│   ├── migrate/                     # Primary database migrations
│   ├── cache_migrate/
│   ├── queue_migrate/
│   ├── cable_migrate/
│   └── seeds/
│       ├── admin_user.rb            # All environments
│       ├── sample_data.rb           # Development only
│       └── projects.rb              # Development only
├── test/
│   ├── components/
│   ├── controllers/
│   ├── jobs/
│   ├── models/
│   ├── policies/
│   ├── system/
│   ├── tools/                       # MCP tool tests
│   └── test_helpers/
│       └── session_test_helper.rb
├── .kamal/
│   ├── secrets                      # Runtime credentials (gitignored)
│   └── hooks/
│       └── pre-deploy
├── Procfile.dev                     # web + css + jobs
└── docker-compose.yml               # PostgreSQL 17 only
```
