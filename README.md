# Guild Board — Rails 8 Production Boilerplate

A production-ready Rails 8 application template delivered as a single `template.rb` file. Run one command to scaffold a complete, opinionated full-stack application with authentication, authorization, UI components, background jobs, and a deployment pipeline — all without Node.js.

```bash
rails new my_app -d postgresql -c tailwind -m path/to/template.rb
```

---

## Table of Contents

- [A. Project Introduction & Technology Stack](#a-project-introduction--technology-stack)
- [B. Local Development Setup](#b-local-development-setup)
- [C. UI Components (ViewComponent)](#c-ui-components-viewcomponent)
- [D. Testing](#d-testing)
- [E. Deployment (Kamal 2)](#e-deployment-kamal-2)
- [F. Directory Structure](#f-directory-structure)
- [G. Optional Features Guide](#g-optional-features-guide)
- [H. Scaling Guide](#h-scaling-guide)
- [I. Frontend Expansion Guide](#i-frontend-expansion-guide)
- [J. Kamal Deployment Checklist](#j-kamal-deployment-checklist)

---

## A. Project Introduction & Technology Stack

Guild Board applies a "Built-in First" philosophy: every architectural choice maximizes Rails 8 native capabilities. Only 4 external gems are added beyond Rails defaults (pundit, pagy, lograge, view_component). There is no Node.js, no webpack, and no build step.

### Technology Stack

| Layer | Choice | Version |
|---|---|---|
| Ruby | MRI | ~> 3.4 |
| Rails | Full-stack | ~> 8.1 |
| Database | PostgreSQL | 17.x |
| Frontend | Hotwire (Turbo + Stimulus) | turbo-rails ~> 2.0, stimulus-rails ~> 1.3 |
| CSS | Tailwind CSS v4 | tailwindcss-rails ~> 4.2 |
| Asset Pipeline | Propshaft + Import Maps | propshaft ~> 1.1, importmap-rails ~> 2.1 |
| Background Jobs | SolidQueue | ~> 1.3 |
| Caching | SolidCache | ~> 1.0 |
| WebSocket | SolidCable | ~> 3.0 |
| Auth | Rails 8 built-in + custom sign-up | bcrypt ~> 3.1 |
| Authorization | Pundit | ~> 2.5 |
| Pagination | Pagy | ~> 43.0 |
| Logging | Lograge | ~> 0.14 |
| UI Components | ViewComponent | ~> 4.4 |
| Deployment | Kamal 2 | ~> 2.10 |
| Web Server | Puma behind Thruster | puma ~> 6.5, thruster ~> 0.1 |

### Key Architecture Principles

**Zero-Build JavaScript.** Tailwind CSS v4 uses a standalone Rust-based CLI (no Node.js required). Import Maps serve ES modules directly from the browser. Propshaft replaces Sprockets for straightforward asset serving.

**Solid Stack (no Redis).** Background jobs (SolidQueue), caching (SolidCache), and WebSocket (SolidCable) are all database-backed, running on the same PostgreSQL server as the application. No separate infrastructure is required.

**Proxy Architecture.**

```
[Internet] → [kamal-proxy] → [Thruster] → [Puma]
               SSL/HTTP2       gzip           Rails app
               routing         asset caching
               error pages     X-Sendfile
```

---

## B. Local Development Setup

### Prerequisites

- Ruby 3.4 or later (managed via rbenv, asdf, or mise)
- Docker (for PostgreSQL 17 only — the Rails app runs natively)
- Bundler 2.x

### Three-Step Setup

```bash
# Step 1: Start PostgreSQL 17 via Docker (DB only)
docker-compose up db -d

# Step 2: Install dependencies, create databases, run migrations, seed data
bin/setup

# Step 3: Start the development server
bin/dev
```

`bin/dev` uses Foreman to run three processes in parallel via `Procfile.dev`:

| Process | Command | Description |
|---|---|---|
| `web` | `rails server -p 3000` | Rails application server |
| `css` | Tailwind watcher | Rebuilds CSS on file changes |
| `jobs` | SolidQueue worker | Processes background jobs |

> **Note (Hybrid Docker):** Only PostgreSQL runs inside Docker. The Rails app itself runs natively on your machine via `bin/dev`. This avoids Docker networking overhead and makes debugging straightforward.

### Multi-Database Setup

The template configures four logical databases on a single PostgreSQL server. Each maps to a separate Rails database connection role:

| Database name | Purpose | Rails connection |
|---|---|---|
| `app_primary` | Application data | `primary` (default) |
| `app_cache` | SolidCache storage | `cache` |
| `app_queue` | SolidQueue job storage | `queue` |
| `app_cable` | SolidCable pub/sub | `cable` |

Each database has its own migration directory (`db/migrate/`, `db/cache_migrate/`, `db/queue_migrate/`, `db/cable_migrate/`) and is managed independently via Rails multi-DB conventions.

---

## C. UI Components (ViewComponent)

Ten pre-built ViewComponents are included under `app/components/`. All components inherit from `ApplicationComponent < ViewComponent::Base` and use Tailwind CSS utility classes directly — no external UI library dependency.

### 1. ButtonComponent

Renders a `<button>` or `<a>` tag with three visual variants.

**Variants:** `primary` (indigo), `secondary` (white/ring), `danger` (red)

```erb
<%= render ButtonComponent.new(variant: :primary) do %>
  Save Changes
<% end %>

<%= render ButtonComponent.new(variant: :danger, tag: :a, href: delete_path) do %>
  Delete
<% end %>
```

### 2. CardComponent

A container component with optional `title`, `body`, and `footer` slots.

**Variants:** `default` (white with shadow), `bordered` (white with border)

```erb
<%= render CardComponent.new(variant: :bordered) do |c| %>
  <% c.with_title { "Card Title" } %>
  <% c.with_body  { "Card content goes here." } %>
<% end %>
```

### 3. BadgeComponent

A compact inline label for status indicators. Requires a `label:` argument.

**Variants:** `info` (blue), `success` (green), `warning` (yellow), `error` (red)

```erb
<%= render BadgeComponent.new(variant: :success, label: "Active") %>
<%= render BadgeComponent.new(variant: :warning, label: "Pending") %>
```

### 4. FlashComponent

Renders all Rails flash messages (notice, alert, error) with auto-dismiss via the `flash` Stimulus controller. Skips rendering when the flash hash is empty.

```erb
<%# In application layout — pass the flash hash directly %>
<%= render FlashComponent.new(flash: flash) %>
```

### 5. ModalComponent

A dialog overlay managed by the `modal` Stimulus controller. Supports a `trigger` slot (the element that opens the modal) and a `body` slot (modal content). Closes on backdrop click.

```erb
<%= render ModalComponent.new do |m| %>
  <% m.with_trigger { render ButtonComponent.new { "Open Modal" } } %>
  <% m.with_body    { "Modal content here." } %>
<% end %>
```

### 6. DropdownComponent

A relative-positioned dropdown menu managed by the `dropdown` Stimulus controller. Accepts a `trigger` slot and multiple `items` slots.

```erb
<%= render DropdownComponent.new do |d| %>
  <% d.with_trigger { "Menu" } %>
  <% d.with_items   { link_to "Profile", profile_path, role: "menuitem" } %>
  <% d.with_items   { link_to "Sign out", session_path, data: { turbo_method: :delete }, role: "menuitem" } %>
<% end %>
```

### 7. FormFieldComponent

Wraps a `form_with` field with a label, styled input, and inline validation error messages. Applies error ring styles automatically when `error_messages` are present.

**Input types:** `:text` (default), `:email`, `:password`, `:select`, `:textarea`

```erb
<%= form_with model: @user do |f| %>
  <%= render FormFieldComponent.new(
        form: f, field_name: :email, type: :email,
        label: "Email address",
        error_messages: @user.errors[:email],
        required: true) %>
<% end %>
```

### 8. EmptyStateComponent

A centered empty-state display with an optional `icon` slot and `action` slot (for a CTA button).

```erb
<%= render EmptyStateComponent.new(message: "No records found.") do |e| %>
  <% e.with_action { render ButtonComponent.new { "Create your first record" } } %>
<% end %>
```

### 9. PaginationComponent

Renders a Pagy navigation bar. Skips rendering automatically when there is only one page (`pagy.pages <= 1`).

```erb
<%# Controller: @pagy, @records = pagy(Record.all) %>
<%= render PaginationComponent.new(pagy: @pagy) %>
```

### 10. NavbarComponent

A responsive navigation bar with desktop links and a mobile hamburger menu, managed by the `navbar` Stimulus controller. Conditionally renders authenticated vs. unauthenticated links based on the `user:` argument.

```erb
<%# In application layout %>
<%= render NavbarComponent.new(user: Current.user) %>
```

---

## D. Testing

The template configures Minitest (Rails default) with Capybara and headless Chrome for system tests.

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
```

### Test Organization

| Directory | Contents |
|---|---|
| `test/models/` | Model unit tests |
| `test/policies/` | Pundit policy tests |
| `test/components/` | ViewComponent unit tests |
| `test/integration/` | Controller and request integration tests |
| `test/system/` | End-to-end browser tests (Capybara) |

### Code Quality

```bash
# Lint with rubocop-rails-omakase style guide
bundle exec rubocop

# Static security analysis
bundle exec brakeman
```

> **Note:** System tests require Google Chrome installed locally. The Selenium WebDriver (`~> 4.27`) manages the headless Chrome session.

---

## E. Deployment (Kamal 2)

### Proxy Architecture

```
[Internet] → [kamal-proxy] → [Thruster] → [Puma]
               SSL/HTTP2       gzip           Rails app
               routing         asset caching
               error pages     X-Sendfile
```

**kamal-proxy** handles SSL termination, HTTP/2, and zero-downtime routing at the host level. **Thruster** runs inside the container and handles gzip compression, asset caching, and `X-Sendfile`. **Puma** serves the Rails application.

### Configuration Files

| File | Purpose |
|---|---|
| `config/deploy.yml` | Main Kamal deployment configuration |
| `.kamal/secrets` | Runtime secrets (not committed to git) |
| `.kamal/secrets.example` | Template for secrets — commit this |
| `.kamal/hooks/pre-deploy` | Pre-deployment checks (clean git state) |

### Deployment Commands

```bash
# First-time server setup (provisions server, pulls image, starts containers)
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

### Key deploy.yml Settings

The generated `config/deploy.yml` includes two server roles:

- **web** — Rails application (served via Thruster + Puma on port 3000)
- **job** — SolidQueue worker (`bundle exec jobs`)

Both roles can point to the same server IP for single-server deployments.

```yaml
proxy:
  host: YOUR_DOMAIN
  app_port: 3000
  healthcheck:
    path: /up
    interval: 3
    timeout: 3
  # SSL: Uncomment for automatic Let's Encrypt (single server)
  # ssl: true
  # ssl_redirect: true
```

### Health Checks

| Endpoint | Type | Description |
|---|---|---|
| `/up` | Liveness | Rails built-in; returns 200 when the app process is running |
| `/health` | Readiness | Custom endpoint; performs a database connectivity check |

> **SSL Note:** Automatic Let's Encrypt SSL is supported by kamal-proxy but is commented out in the generated config. Uncomment `ssl: true` and `ssl_redirect: true` in `config/deploy.yml` after confirming your domain's DNS resolves to the server IP.

---

## F. Directory Structure

```
my_app/
├── app/
│   ├── components/              # ViewComponent (10 components)
│   │   ├── application_component.rb
│   │   ├── button_component.rb
│   │   ├── card_component.rb
│   │   ├── badge_component.rb
│   │   ├── flash_component.rb
│   │   ├── modal_component.rb
│   │   ├── dropdown_component.rb
│   │   ├── form_field_component.rb
│   │   ├── empty_state_component.rb
│   │   ├── pagination_component.rb
│   │   └── navbar_component.rb
│   ├── controllers/
│   │   ├── admin/               # Admin namespace (Pundit role checks)
│   │   ├── application_controller.rb
│   │   ├── registrations_controller.rb   # Custom sign-up
│   │   ├── sessions_controller.rb        # Rails 8 auth generator
│   │   └── passwords_controller.rb       # Rails 8 auth generator
│   ├── javascript/
│   │   └── controllers/         # Stimulus controllers
│   │       ├── flash_controller.js
│   │       ├── modal_controller.js
│   │       ├── dropdown_controller.js
│   │       └── navbar_controller.js
│   ├── models/
│   │   ├── current.rb
│   │   └── user.rb              # Role enum, password validation
│   ├── policies/                # Pundit authorization policies
│   │   ├── application_policy.rb
│   │   └── admin/
│   └── views/
│       ├── layouts/
│       └── components/          # ViewComponent ERB templates
├── config/
│   ├── database.yml             # Multi-DB (primary/cache/queue/cable)
│   ├── deploy.yml               # Kamal 2 deployment configuration
│   ├── initializers/
│   │   ├── pagy.rb
│   │   ├── pundit.rb
│   │   └── lograge.rb
│   └── locales/
│       ├── defaults/            # General UI translations (ko.yml, en.yml)
│       └── models/              # Model attribute translations
├── db/
│   ├── migrate/                 # Primary database migrations
│   ├── cache_migrate/           # SolidCache schema migrations
│   ├── queue_migrate/           # SolidQueue schema migrations
│   ├── cable_migrate/           # SolidCable schema migrations
│   └── seeds/
│       ├── admin_user.rb
│       └── sample_data.rb
├── test/
│   ├── components/              # ViewComponent tests
│   ├── integration/
│   ├── models/
│   ├── policies/                # Pundit policy tests
│   └── system/                  # Capybara end-to-end tests
├── .kamal/
│   ├── secrets                  # Runtime credentials (gitignored)
│   ├── secrets.example          # Template (committed)
│   └── hooks/
│       └── pre-deploy           # Git clean-state check
├── Procfile.dev                 # Foreman: web + css + jobs
└── docker-compose.yml           # PostgreSQL 17 only
```

---

## G. Optional Features Guide

### G.1 Active Record Encryption

Rails 7.1+ includes built-in transparent encryption for model attributes. Use it to encrypt sensitive fields (e.g., tokens, PII) at rest in the database.

**Step 1: Generate encryption keys.**

```bash
bin/rails db:encryption:init
```

This outputs three keys. Copy the entire block.

**Step 2: Add the keys to Rails credentials.**

```bash
bin/rails credentials:edit
```

Paste the generated output under the `active_record_encryption:` key:

```yaml
active_record_encryption:
  primary_key: <generated>
  deterministic_key: <generated>
  key_derivation_salt: <generated>
```

**Step 3: Declare encrypted attributes in the model.**

```ruby
class User < ApplicationRecord
  encrypts :phone_number
  encrypts :api_token, deterministic: true  # deterministic = searchable
end
```

> **Note:** Keys are environment-specific. Production keys must be set separately — either via `RAILS_MASTER_KEY` pointing to `config/credentials/production.yml.enc`, or by injecting `ACTIVE_RECORD_ENCRYPTION_PRIMARY_KEY` and related environment variables directly.

---

### G.2 Rate Limit Store Customization

The boilerplate uses Rails 8's built-in `rate_limit` method. The store it uses is determined by `config.cache_store`.

**Default (production and test):** SolidCache — database-backed via the `cache` PostgreSQL database.

```ruby
# config/environments/production.rb
config.cache_store = :solid_cache_store
```

**Development override — memory store (no DB required):**

Add to `config/environments/development.rb`:

```ruby
config.cache_store = :memory_store
```

**Switching to Redis:**

1. Add `gem "redis"` to the Gemfile and run `bundle install`.
2. Update `config/environments/production.rb`:

```ruby
config.cache_store = :redis_cache_store, { url: ENV.fetch("REDIS_URL") }
```

The `rate_limit` calls in `SessionsController`, `PasswordsController`, and `RegistrationsController` will automatically use the new store — no changes to controller code are needed.

---

### G.3 Password Policy Strengthening

The default policy enforces a minimum of 8 characters, applied in `app/models/user.rb`:

```ruby
validates :password, length: { minimum: 8 }, if: -> { new_record? || password.present? }
```

To require greater complexity, add a `format:` validation alongside the length check:

```ruby
COMPLEXITY_REGEX = /\A(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[[:^alnum:]])/

validates :password,
  length: { minimum: 12 },
  format: {
    with: COMPLEXITY_REGEX,
    message: :complexity
  },
  if: -> { new_record? || password.present? }
```

Add the corresponding I18n key to `config/locales/models/`:

```yaml
# config/locales/models/user.ko.yml
ko:
  errors:
    models:
      user:
        attributes:
          password:
            complexity: "은(는) 대문자, 소문자, 숫자, 특수문자를 각각 하나 이상 포함해야 합니다."
```

---

## H. Scaling Guide

Start with the Solid Stack. Monitor. Migrate one component at a time when you hit a specific, observed bottleneck — not preemptively.

### H.1 When to Consider Redis

| Component | Signal to migrate |
|---|---|
| **SolidQueue** | Job volume causes noticeable DB I/O contention, or you need sub-second job pickup latency |
| **SolidCache** | Cache read volume measurably impacts primary DB query performance |
| **SolidCable** | Real-time connection count grows beyond what long-polling handles efficiently |

For most applications serving under a few thousand concurrent users, the Solid Stack on a well-resourced PostgreSQL server is sufficient.

---

### H.2 Solid Cable → Redis Adapter

1. Add `gem "redis"` to the Gemfile and run `bundle install`.

2. Update `config/cable.yml`:

```yaml
production:
  adapter: redis
  url: <%= ENV.fetch("REDIS_URL") { "redis://localhost:6379/1" } %>
  channel_prefix: <%= Rails.application.name.underscore %>_production
```

3. Optionally remove the `cable` database entry from `config/database.yml` and the `db/cable_migrate/` directory.

4. Deploy and verify WebSocket connections in the browser developer tools Network tab (look for `101 Switching Protocols`).

---

### H.3 Solid Queue → Sidekiq or GoodJob

**Option A: Sidekiq (requires Redis)**

1. Add `gem "sidekiq"` to the Gemfile and run `bundle install`.
2. Set the queue adapter in `config/application.rb`:

```ruby
config.active_job.queue_adapter = :sidekiq
```

3. Remove the `queue` database from `config/database.yml` and its migration directory `db/queue_migrate/`.
4. Remove the `jobs:` process from `Procfile.dev` and replace with `bundle exec sidekiq`.
5. Add a Sidekiq process to `config/deploy.yml` under `servers:`.

**Option B: GoodJob (stays PostgreSQL-backed)**

1. Add `gem "good_job"` to the Gemfile and run `bundle install`.
2. Set the queue adapter:

```ruby
config.active_job.queue_adapter = :good_job
```

3. Follow the same cleanup steps for the `queue` database. GoodJob stores its data in the primary database by default.

> **Note:** Sidekiq requires Redis. GoodJob remains PostgreSQL-backed, making it a lower-complexity migration from SolidQueue.

---

### H.4 Solid Cache → Redis Cache Store

1. Add `gem "redis"` to the Gemfile and run `bundle install`.

2. Update `config/environments/production.rb`:

```ruby
config.cache_store = :redis_cache_store, {
  url: ENV.fetch("REDIS_URL"),
  expires_in: 1.day
}
```

3. Optionally remove the `cache` database from `config/database.yml` and the `db/cache_migrate/` directory.

4. The `rate_limit` calls in all three auth controllers will automatically use the Redis store — no controller changes are required.

---

## I. Frontend Expansion Guide

### I.1 When to Migrate from Import Maps

The zero-build Import Maps setup covers the vast majority of use cases. Consider migrating when you encounter one or more of these specific triggers:

- You need TypeScript with compile-time type checking.
- An NPM package you require does not ship an ESM-compatible build.
- You are bundling large libraries (e.g., Chart.js, Three.js, D3) where tree-shaking provides a meaningful size reduction.
- Your team requires a CSS preprocessor (Sass, PostCSS plugins) beyond what Tailwind v4 provides.

If none of these apply, stay with Import Maps.

---

### I.2 Import Maps → jsbundling-rails (esbuild) Migration

1. Add `gem "jsbundling-rails"` to the Gemfile and run `bundle install`.
2. Run the esbuild installer:

```bash
bin/rails javascript:install:esbuild
```

3. Remove `gem "importmap-rails"` from the Gemfile and run `bundle install`.
4. Delete `config/importmap.rb`.
5. Review `app/assets/config/manifest.js` — add `//= link_tree ../../javascript .js` if the installer did not update it.
6. Node.js is now required on all development machines and CI. Install it via your version manager (`mise`, `nvm`, or `asdf`).

---

### I.3 Procfile.dev Changes

**Before (Import Maps, zero-build):**

```
web: bin/rails server -p 3000
css: bin/rails tailwindcss:watch
jobs: bundle exec jobs
```

**After (esbuild):**

```
web: bin/rails server -p 3000
css: bin/rails tailwindcss:watch
js: yarn build --watch
jobs: bundle exec jobs
```

---

### I.4 CI Workflow Changes

After migrating to esbuild, update `.github/workflows/ci.yml` to add Node.js setup before the test steps:

```yaml
- name: Set up Node.js
  uses: actions/setup-node@v4
  with:
    node-version-file: .node-version
    cache: yarn

- name: Install JavaScript dependencies
  run: yarn install --frozen-lockfile

- name: Build JavaScript assets
  run: yarn build
```

Insert these steps before the `Precompile assets` step (if present) and before running `bin/rails test`.

---

## J. Kamal Deployment Checklist

### J.1 SSL Configuration (Let's Encrypt)

SSL via Let's Encrypt is supported by kamal-proxy but is commented out in the generated `config/deploy.yml`. Complete this checklist before enabling it.

- [ ] Domain DNS A record points to the server IP
- [ ] Ports 80 and 443 are open on the server (Let's Encrypt HTTP-01 challenge requires port 80)
- [ ] `proxy.host` in `config/deploy.yml` is set to your domain (not an IP address)
- [ ] Uncomment and configure the SSL block:

```yaml
proxy:
  host: yourdomain.com
  app_port: 3000
  ssl: true
  ssl_redirect: true
  forward_headers: true
  healthcheck:
    path: /up
    interval: 3
    timeout: 3
```

---

### J.2 forward_headers Warning

When `ssl: true` is set, kamal-proxy terminates SSL and forwards plain HTTP to Thruster and Puma. This means Rails receives unencrypted requests and cannot detect HTTPS on its own.

**`forward_headers: true` must be explicitly set** when SSL is enabled. Without it:

- `request.ssl?` returns `false` inside Rails
- `config.force_ssl` does not redirect correctly
- Secure cookie flags may not be set
- CSRF token verification can fail on form submissions

With `forward_headers: true`, kamal-proxy passes `X-Forwarded-For` and `X-Forwarded-Proto: https` to the app. Rails reads `X-Forwarded-Proto` via its default middleware (`ActionDispatch::RemoteIp`, `ActionDispatch::SSL`) to correctly identify the request as HTTPS.

---

### J.3 Health Check Verification

- [ ] `/up` returns HTTP 200 (Rails built-in liveness — checks the process is alive)
- [ ] `/health` returns HTTP 200 (custom readiness — verifies database connectivity)
- [ ] In SSL environment, both endpoints respond correctly over HTTPS
- [ ] Kamal proxy health check configuration is present in `config/deploy.yml`:

```yaml
proxy:
  healthcheck:
    path: /up
    interval: 3
    timeout: 3
```

- [ ] `app_port` in `config/deploy.yml` matches the Puma port (default: `3000`)
- [ ] After `kamal setup`, verify with:

```bash
curl -I https://yourdomain.com/up
curl -I https://yourdomain.com/health
```

Both should return `HTTP/2 200`. A `503` on `/health` indicates a database connectivity problem; check `DATABASE_URL` in `.kamal/secrets`.
