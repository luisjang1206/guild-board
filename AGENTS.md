# AGENTS.md

## Project Context

Guild Board is a Rails 8.1 production boilerplate for project/task management with a kanban board UI. It follows a "Built-in First" philosophy -- maximizing Rails 8 native capabilities with only 4 external gems beyond defaults (pundit, pagy, lograge, view_component). Zero Node.js dependency. Includes an MCP server (fast-mcp) for AI agent integration.

### Tech Stack Summary

| Layer | Technology |
| --- | --- |
| Language | Ruby 3.4.8 |
| Framework | Rails 8.1.2 |
| Database | PostgreSQL 17 (4 logical DBs: primary, cache, queue, cable) |
| Frontend | Hotwire (Turbo + Stimulus), Tailwind CSS v4, Propshaft, Import Maps |
| Auth | Rails 8 built-in (has_secure_password, session-based) + Pundit |
| Pagination | Pagy ~43.0 |
| Components | ViewComponent ~4.4 |
| Real-time | ActionCable + Turbo Streams + SolidCable |
| Background Jobs | SolidQueue |
| Caching | SolidCache |
| Deployment | Kamal 2 (kamal-proxy + Thruster + Puma) |
| MCP | fast-mcp gem |

### Project Layout

```
app/
  controllers/        # ApplicationController, Admin::*, resource controllers
    concerns/         # Authentication, ActivityLoggable
  models/             # Domain models + Current (ActiveSupport::CurrentAttributes)
    concerns/         # Positionable
  components/         # 17 ViewComponents (ApplicationComponent base)
  policies/           # Pundit policies (ApplicationPolicy base)
  tools/              # MCP tools (ApplicationTool < FastMcp::Tool)
    concerns/         # McpAuthentication
  javascript/
    controllers/      # 15 Stimulus controllers
  views/              # ERB templates + Turbo Stream templates
  assets/
    tailwind/         # Tailwind CSS v4 source
config/
  routes.rb           # Admin namespace + project-scoped resources
  importmap.rb        # ES module pins (sortablejs from CDN)
  deploy.yml          # Kamal 2 deployment
db/
  migrate/            # Primary DB migrations
  queue_migrate/      # SolidQueue migrations
  cache_migrate/      # SolidCache migrations
  cable_migrate/      # SolidCable migrations
  seeds/              # Modular seed files (loaded alphabetically)
docs/                 # PRD, TSD, ROADMAP, design guides
test/                 # Minitest (models, policies, components, controllers, tools, system)
```

## Operational Commands

### Development

```bash
docker-compose up db -d          # Start PostgreSQL via Docker
bin/setup                        # Install deps, create DBs, migrate, seed
bin/dev                          # Start dev server (Rails + Tailwind watcher + SolidQueue worker)
```

### Testing

```bash
bin/rails test                           # All unit/integration tests
bin/rails test:system                    # System tests (Capybara + headless Chrome)
bin/rails test test/models/user_test.rb  # Single file
bin/rails test test/models/user_test.rb:42  # Single test by line number
PARALLEL_WORKERS=1 bin/rails test        # Use when pg gem segfaults with parallel workers
bin/ci                                   # Full CI suite (lint + security + tests)
```

### Code Quality

```bash
bin/rubocop          # Lint (rubocop-rails-omakase style)
bin/brakeman         # Static security analysis
bin/bundler-audit    # Gem vulnerability audit
bin/importmap audit  # JS dependency audit
```

### Database

```bash
bin/rails db:prepare    # Prepare all databases (4 logical DBs)
bin/rails db:migrate    # Run primary migrations
bin/rails db:seed       # Seed data (modular files in db/seeds/)
```

## Golden Rules

### Immutable Constraints

1. Never add Node.js or npm/yarn/pnpm to the project. Zero JS build tools.
2. Never exceed 4 external gems beyond Rails defaults (pundit, pagy, lograge, view_component). The fast-mcp gem is the MCP integration exception.
3. Never hardcode secrets. Use Rails credentials (`bin/rails credentials:edit`) or environment variables.
4. Never bypass Pundit authorization in controllers. All actions default to `false` in ApplicationPolicy.
5. Never modify or destroy an ActivityLog record after creation. It is read-only by design.
6. Never use ActiveRecord polymorphic associations for Task creator or Comment author. These use validated string fields (`creator_type`/`creator_id`, `author_type`/`author_id`) with valid types `"user"` and `"agent"`.

### Do's

- Use `params.expect(model: [...])` for strong parameters (Rails 8 syntax).
- Use `Current.user` for the current authenticated user (not `current_user` directly).
- Use `Task.active` scope to exclude soft-deleted tasks in all queries.
- Use `positionable scope: :column_name` concern for ordered models (Task, BoardColumn, Checklist).
- Use `includes()` for eager loading to prevent N+1 queries (see BoardsController pattern).
- Use `allow_unauthenticated_access` for public routes.
- Use Neo-Brutalism style for user-facing pages, Modern UI for admin pages.
- Use the `STYLES` hash + `style_for` helper pattern for ViewComponent style variants.
- Use `log_activity` from ActivityLoggable concern to record user actions asynchronously via ActivityLogJob.
- Use Turbo Streams for real-time updates. Models broadcast via `after_create_commit` / `after_update_commit`.

### Don'ts

- Do not use `params.require(:model).permit(...)` -- use `params.expect()` instead.
- Do not use `:items` or `:size` with Pagy -- use `:limit` and `:slots`.
- Do not delete tasks with `destroy` -- use `soft_delete` method.
- Do not create new Stimulus controllers for functionality covered by existing ones (drag, filter, frame_modal, clipboard, board, column_edit, column_drag, add_column).
- Do not add CSS frameworks or JS libraries beyond what Import Maps provides. Pin external JS via `config/importmap.rb`.
- Do not skip `authorize @resource` calls in controller actions.
- Do not mix design systems -- Neo-Brutalism and Modern UI are context-specific.

## Standards & References

### Coding Conventions

- **Ruby style:** rubocop-rails-omakase. Run `bin/rubocop` before committing.
- **Frozen string literals:** Add `# frozen_string_literal: true` to new Ruby files.
- **Controller pattern:** `before_action :set_project` + `before_action :set_resource` + Pundit `authorize`.
- **Model naming:** Singular (Task, BoardColumn). Table names are plural (tasks, board_columns).
- **Component naming:** `{Name}Component` class in `app/components/{name}_component.rb` with `{name}_component.html.erb` template.
- **Stimulus controller naming:** `{name}_controller.js` registered automatically via `pin_all_from`.
- **MCP tool naming:** `{Name}Tool` class in `app/tools/{name}_tool.rb`, inheriting `ApplicationTool`.
- **View template location:** `app/views/{controller_name}/{action}.html.erb` + `{action}.turbo_stream.erb` for Turbo responses.
- **i18n files:** `config/locales/defaults/` for general translations, `config/locales/models/` for model-specific.

### Git Strategy

- **Main branch:** `main`
- **Commit format:** Conventional Commits (`feat:`, `fix:`, `refactor:`, `test:`, `docs:`, `chore:`, `style:`)
- **Scope convention:** `feat(i18n):`, `fix(mcp):`, `refactor(components):` -- use module/area name
- **Branch naming:** Feature branches from `main` (e.g., `style/neo-brutalism-guide`)

### Maintenance Policy

When rules in any AGENTS.md diverge from actual code behavior, update the AGENTS.md to reflect reality and flag the divergence in a commit message.

## Environment Variables

### Development / Test

| Variable | Description |
| --- | --- |
| `DB_HOST` | PostgreSQL host (default: localhost) |
| `DB_USER` | PostgreSQL username (default: postgres) |
| `DB_PASSWORD` | PostgreSQL password |
| `DB_PORT` | PostgreSQL port (default: 5432) |
| `RAILS_MAX_THREADS` | Puma thread count (default: 5) |
| `ADMIN_EMAIL` | Seed admin email |
| `ADMIN_PASSWORD` | Seed admin password |

### Production (Kamal secrets)

| Variable | Description |
| --- | --- |
| `RAILS_MASTER_KEY` | Rails credentials decryption key |
| `DATABASE_URL` | Primary database connection string |
| `MCP_ALLOWED_ORIGIN` | Allowed CORS origin for MCP server |
| `APP_DOMAIN` | Application domain for deployment |
| `KAMAL_REGISTRY_USERNAME` | Container registry username |
| `KAMAL_REGISTRY_PASSWORD` | Container registry password |

## Context Map (Action-Based Routing)

- **[Domain Models & Concerns](./app/models/)** -- When modifying models, associations, validations, scopes, or the Positionable concern
- **[Controllers & Auth](./app/controllers/)** -- When modifying request handling, authentication flow, or activity logging
- **[Pundit Policies](./app/policies/)** -- When modifying authorization rules
- **[ViewComponents](./app/components/)** -- When creating or modifying UI components with dual style system
- **[Stimulus Controllers](./app/javascript/controllers/)** -- When adding frontend interactivity
- **[MCP Tools](./app/tools/)** -- When modifying AI agent integration tools
- **[Design System](./docs/DESIGN_SYSTEM.md)** -- When applying Neo-Brutalism or Modern UI styles
- **[Design Guide](./docs/DESIGN_GUIDE.md)** -- When implementing Neo-Brutalism UI elements
- **[Project Roadmap](./docs/ROADMAP.md)** -- When planning new features or checking project status
- **[Deployment Config](./config/deploy.yml)** -- When modifying Kamal 2 deployment settings

<!-- custom -->
<!-- Add project-specific notes below. This block is preserved across regeneration. -->
<!-- /custom -->
