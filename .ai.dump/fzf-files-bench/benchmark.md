# fzf-files benchmark

Repo: `/Users/tai/Developer/500kv/rush` (245 visible files, 216k+ on disk)

## Baseline (v1 — 3-part parallel fd with `sort -u`)

| Metric                     | Value      |
| -------------------------- | ---------- |
| Wall clock (mean ± σ)      | 505 ± 4 ms |
| User time                  | 192 ms     |
| System time                | 4005 ms    |
| RSS                        | 12.5 MB    |
| Page reclaims              | 7434       |
| Involuntary context switch | 20127      |
| Process count              | ~15+       |

### Root causes

1. cmd3 (`fd --hidden --no-ignore -E .git`) traversed the **entire tree**
   including nested `node_modules/` (26k files in `fe/app/node_modules`). The
   `gitignore_excludes` function only read the **root** `.gitignore` and skipped
   path-based patterns like `infra/osrm-data/`, missing nested `.gitignore`
   files entirely.
2. `gitignore_excludes` spawned a 6-process pipeline
   (`sed | sort | grep | sed | tr`) plus `eval` for the final command assembly.
3. `wait | awk '!seen[$0]++'` — dedup was **completely broken**. `wait` produces
   no stdout; bg jobs wrote directly to the script's stdout, bypassing awk.
   Worked by accident (no duplicates in test repos).
4. macOS `/usr/bin/awk` (nawk) rejects `!seen[$0]++` — no associative array
   support.
5. `has_glob()` bracket expression `[*?\[` was malformed, so `**/local` was
   misclassified as a concrete dir.

## Final (v4 — no dedup needed, git check-ignore)

| Metric                     | Value                |
| -------------------------- | -------------------- |
| Wall clock (mean ± σ)      | 45 ± 4 ms            |
| User time                  | 16 ms                |
| System time                | 22 ms                |
| RSS                        | 10 MB                |
| Page reclaims              | 3644                 |
| Involuntary context switch | 325                  |
| Process count              | 4 (bash, 2× fd, git) |

### Speedup: **11x wall clock, 182x system time**

### Changes from v1

1. **Eliminated whole-tree `--no-ignore` scans.** Include files checked at repo
   root only via bash glob — no traversal.
2. **Dropped `include_dir_globs`** (`**/local`). Glob dir search requires
   `fd --no-ignore --type d` which still traverses the entire tree (~1s in
   monorepos). Not worth the cost for ctrl-t.
3. **Eliminated dedup entirely.** Root globs pipe through
   `git check-ignore --stdin` so only actually-gitignored files are emitted — no
   overlap with base fd. Removed perl dependency.
4. **Collapsed to 2 background jobs** (base fd + everything else) instead of
   15+.
5. **Removed** the `gitignore_excludes` pipeline, `eval`, regex-building loops,
   and `has_glob()`.
6. **Portable fd detection** — auto-detects `fdfind` on Debian/Ubuntu.

### Intermediate versions

- **v2** (45ms): broken `wait | awk` dedup — results were unfiltered.
- **v3** (75ms): fixed dedup with perl, but perl startup added ~55ms overhead.
- **v4** (45ms): eliminated dedup entirely via `git check-ignore` filtering.

## Correctness verification

Tested against `500kv/rush` (monorepo: Go backend, React Native + Vite frontend,
infra). Gitignore sources: root `.gitignore`, `fe/.gitignore`,
`fe/app/.gitignore`, `be/.gitignore`, global `~/.gitignore`.

### Correctly included (gitignored but in include list)

| Path                                  | Source        |
| ------------------------------------- | ------------- |
| `.ai.dump/token-refresh/q1.md`        | include_dirs  |
| `.ai.dump/token-refresh/review-r1.md` | include_dirs  |
| `.dump/todo.md`                       | include_dirs  |
| `.env.local`                          | include_files |

### Correctly excluded (gitignored, not in include list)

216k+ files on disk excluded. Sample:

| Path                            | Ignored by            |
| ------------------------------- | --------------------- |
| `node_modules/`                 | root `.gitignore`     |
| `.bun/`                         | root `.gitignore`     |
| `infra/osrm-data/`              | root `.gitignore`     |
| `infra/superset/superset_home/` | root `.gitignore`     |
| `be/gen/`                       | `be/.gitignore`       |
| `be/bin/`                       | `be/.gitignore`       |
| `fe/gen/`                       | `fe/.gitignore`       |
| `fe/app/node_modules/`          | `fe/app/.gitignore`   |
| `.idea/`                        | global `~/.gitignore` |
| `.playwright-mcp/`              | global `~/.gitignore` |
| `.DS_Store`                     | global `~/.gitignore` |
| `.claude/`                      | global `~/.gitignore` |

### Not-ignored files correctly present

245 non-ignored files appear. Sample:

| Path                       | Notes                       |
| -------------------------- | --------------------------- |
| `.env.local.sample`        | Not gitignored despite glob |
| `.gitignore`               | Hidden but tracked          |
| `.devcontainer/Dockerfile` | Hidden dir, tracked         |
| `.github/workflows/be.yml` | Hidden dir, tracked         |
| `AGENTS.md`                | Root file                   |
| `be/internal/auth/jwt.go`  | Backend source              |
| `fe/admin/src/main.tsx`    | Frontend source             |
| `infra/docker-compose.yml` | Infra config                |
| `docs/architecture.md`     | Documentation               |

### Full file list (245 files)

```
.ai.dump/token-refresh/q1.md
.ai.dump/token-refresh/review-r1.md
.devcontainer/.dockerignore
.devcontainer/devcontainer.json
.devcontainer/Dockerfile
.dump/todo.md
.env.local
.env.local.sample
.github/workflows/be.yml
.github/workflows/fe-admin.yml
.github/workflows/fe-app.yml
.gitignore
.prettierrc.yml
.sql-formatter.json
AGENTS.md
be/.gitignore
be/.golangci.yml
be/buf.gen.yaml
be/buf.lock
be/buf.yaml
be/cmd/seed/main.go
be/cmd/server/main.go
be/e2e/auth/login-errors.hurl
be/e2e/auth/login.hurl
be/e2e/auth/logout.hurl
be/e2e/auth/permissions-denied.hurl
be/e2e/auth/permissions.hurl
be/e2e/auth/refresh-token.hurl
be/e2e/auth/unauthenticated.hurl
be/go.mod
be/go.sum
be/internal/auth/context.go
be/internal/auth/cookie.go
be/internal/auth/cookie_test.go
be/internal/auth/jwt.go
be/internal/auth/password.go
be/internal/auth/token.go
be/internal/authsvc/handler.go
be/internal/authz/authz.go
be/internal/db/client.go
be/internal/fleetsvc/handler.go
be/internal/healthsvc/handler.go
be/internal/interceptor/auth.go
be/internal/interceptor/authz.go
be/internal/interceptor/logging.go
be/internal/interceptor/recovery.go
be/internal/locationsvc/handler.go
be/internal/log/log.go
be/internal/middleware/cors.go
be/internal/middleware/default_json.go
be/internal/middleware/request_id.go
be/internal/notificationsvc/handler.go
be/internal/shiftsvc/handler.go
be/internal/tripsvc/handler.go
be/mise-tasks/build
be/mise-tasks/vet
be/mise.toml
be/proto/rush/auth/v1/auth.proto
be/proto/rush/common/v1/common.proto
be/proto/rush/fleet/v1/fleet.proto
be/proto/rush/location/v1/location.proto
be/proto/rush/notification/v1/notification.proto
be/proto/rush/shift/v1/shift.proto
be/proto/rush/trip/v1/trip.proto
be/queries/account.sql
be/queries/auth_identity.sql
be/queries/dispatch_offer.sql
be/queries/driver.sql
be/queries/driver_fleet.sql
be/queries/fleet.sql
be/queries/geofence.sql
be/queries/geofence_alert.sql
be/queries/last_location.sql
be/queries/location_ping.sql
be/queries/notification.sql
be/queries/push_token.sql
be/queries/refresh_token.sql
be/queries/shift.sql
be/queries/shift_template.sql
be/queries/trip.sql
be/queries/trip_event.sql
be/queries/vehicle.sql
be/queries/vehicle_fleet.sql
be/README.md
be/sqlc.yaml
bun.lock
docs/api/design.md
docs/architecture.md
docs/codegen.md
docs/dev.md
docs/domain/auth.md
docs/domain/dispatch.md
docs/domain/fleet.md
docs/domain/geofences.md
docs/domain/location-tracking.md
docs/domain/notifications.md
docs/domain/permissions.md
docs/domain/shifts.md
docs/domain/trip-lifecycle.md
docs/for-agents/backend.md
docs/for-agents/commands.md
docs/for-agents/database.md
docs/for-agents/frontend.md
docs/for-agents/go.md
docs/for-agents/typescript.md
docs/glossary.md
docs/infrastructure.md
docs/readme.md
docs/ref/recurring-scheduling.md
docs/requirements.md
fe/.gitignore
fe/.npmrc
fe/admin/index.html
fe/admin/package.json
fe/admin/readme.md
fe/admin/src/App.test.tsx
fe/admin/src/global.css
fe/admin/src/main.tsx
fe/admin/src/routes/__root.tsx
fe/admin/src/routes/_auth.tsx
fe/admin/src/routes/_auth/dashboard/index.tsx
fe/admin/src/routes/_auth/dispatch/index.tsx
fe/admin/src/routes/_auth/fleet/drivers/index.tsx
fe/admin/src/routes/_auth/fleet/vehicles/index.tsx
fe/admin/src/routes/_auth/forbidden/index.tsx
fe/admin/src/routes/_auth/geofences/$id/edit.tsx
fe/admin/src/routes/_auth/geofences/index.tsx
fe/admin/src/routes/_auth/geofences/new.tsx
fe/admin/src/routes/_auth/map/index.tsx
fe/admin/src/routes/_auth/reports/index.tsx
fe/admin/src/routes/_auth/settings/accounts/index.tsx
fe/admin/src/routes/_auth/settings/notifications/index.tsx
fe/admin/src/routes/_auth/shifts/index.tsx
fe/admin/src/routes/_auth/trips/index.tsx
fe/admin/src/routes/index.tsx
fe/admin/src/routes/login/index.tsx
fe/admin/src/shared/i18n/@types/i18next.d.ts
fe/admin/src/shared/i18n/check.ts
fe/admin/src/shared/i18n/en/common.json
fe/admin/src/shared/i18n/en/fleet.json
fe/admin/src/shared/i18n/en/geofence.json
fe/admin/src/shared/i18n/en/index.ts
fe/admin/src/shared/i18n/en/login.json
fe/admin/src/shared/i18n/en/shell.json
fe/admin/src/shared/i18n/types.ts
fe/admin/src/shared/i18n/vi/common.json
fe/admin/src/shared/i18n/vi/fleet.json
fe/admin/src/shared/i18n/vi/geofence.json
fe/admin/src/shared/i18n/vi/index.ts
fe/admin/src/shared/i18n/vi/login.json
fe/admin/src/shared/i18n/vi/shell.json
fe/admin/src/shared/lib/antd-tokens.ts
fe/admin/src/shared/lib/auth-provider.tsx
fe/admin/src/shared/lib/constants.ts
fe/admin/src/shared/lib/i18n.ts
fe/admin/src/shared/lib/nav-entries.ts
fe/admin/src/shared/lib/queryClient.ts
fe/admin/src/shared/lib/refresh.ts
fe/admin/src/shared/lib/route-guard.ts
fe/admin/src/shared/lib/transport.ts
fe/admin/src/shared/lib/use-badge-counts.ts
fe/admin/src/shared/lib/use-visible-nav.ts
fe/admin/src/shared/mocks/fleet-drivers.ts
fe/admin/src/shared/mocks/fleet-vehicles.ts
fe/admin/src/shared/mocks/geofences.ts
fe/admin/src/shared/stores/uiStore.ts
fe/admin/src/shared/ui/atoms/AppLogo.tsx
fe/admin/src/shared/ui/atoms/NavItemContent.tsx
fe/admin/src/shared/ui/atoms/PlaceholderPage.tsx
fe/admin/src/shared/ui/atoms/SearchButton.tsx
fe/admin/src/shared/ui/atoms/StatusCardItem.tsx
fe/admin/src/shared/ui/atoms/UnderConstruction.tsx
fe/admin/src/shared/ui/molecules/FleetStats.tsx
fe/admin/src/shared/ui/molecules/LanguageSwitcher.tsx
fe/admin/src/shared/ui/molecules/ListPage.tsx
fe/admin/src/shared/ui/molecules/UserMenu.tsx
fe/admin/src/shared/ui/organisms/AppHeader.tsx
fe/admin/src/shared/ui/organisms/CommandPalette.tsx
fe/admin/src/shared/ui/organisms/geofences/GeofenceForm.tsx
fe/admin/src/shared/ui/organisms/geofences/GeofenceMap.tsx
fe/admin/src/shared/ui/organisms/geofences/constants.ts
fe/admin/src/shared/ui/organisms/SidebarNav.tsx
fe/admin/src/vite-env.d.ts
fe/admin/tsconfig.json
fe/admin/vite.config.ts
fe/AGENTS.md
fe/app/.gitignore
fe/app/app.config.ts
fe/app/assets/adaptive-icon.png
fe/app/assets/favicon.png
fe/app/assets/icon.png
fe/app/assets/splash-icon.png
fe/app/babel.config.js
fe/app/metro.config.js
fe/app/package.json
fe/app/readme.md
fe/app/src/app/_layout.tsx
fe/app/src/app/home.tsx
fe/app/src/app/index.tsx
fe/app/src/components/apple-sign-in-button.ios.tsx
fe/app/src/components/google-sign-in-button.tsx
fe/app/tamagui.config.ts
fe/app/tsconfig.json
fe/bun.lock
fe/bunfig.toml
fe/core/package.json
fe/core/src/ability.ts
fe/core/src/clock.test.ts
fe/core/src/clock.ts
fe/core/src/index.ts
fe/core/src/tokens.ts
fe/core/src/useClock.test.tsx
fe/core/src/useClock.ts
fe/core/tsconfig.json
fe/core/vitest.config.ts
fe/docs/ref/rn-gps-tracking.md
fe/eslint.config.mjs
fe/mise-tasks/build/android
fe/mise-tasks/build/ios
fe/mise-tasks/release/android
fe/mise.toml
fe/package.json
fe/prettier.config.mjs
fe/tsconfig.json
infra/db/Dockerfile
infra/db/migrations/001_extensions.sql
infra/db/migrations/002_auth.sql
infra/db/migrations/003_fleet.sql
infra/db/migrations/004_shifts.sql
infra/db/migrations/005_trips.sql
infra/db/migrations/006_locations.sql
infra/db/migrations/007_geofences.sql
infra/db/migrations/008_notifications.sql
infra/db/migrations/009_permissions.sql
infra/docker-compose.yml
infra/mise-tasks/osrm/setup
infra/mise.toml
infra/superset/docker-compose.yml
infra/superset/Dockerfile
infra/superset/superset_config.py
infra/superset/superset-init.sh
mise.toml
package.json
prek.toml
README.md
```

## Authors

- 2026-03-20 18:00: claude (claude-opus-4-6)
  [8649357e-4f62-46de-ab85-2507fff2b5df] Benchmarked and optimized fzf-files
  script
- 2026-03-20 18:30: claude (claude-opus-4-6)
  [8649357e-4f62-46de-ab85-2507fff2b5df] Portability review, fixed dedup,
  dropped glob dirs
- 2026-03-20 19:00: claude (claude-opus-4-6)
  [8649357e-4f62-46de-ab85-2507fff2b5df] Eliminated dedup via git check-ignore,
  manual correctness verification
