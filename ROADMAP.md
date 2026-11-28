# Roadmap

Work in dependency order. Each phase should have a demonstrable, tested deliverable before expanding.

## Phase 0 — Project foundation
- [x] Architecture, security, schema, evaluation, and telemetry docs
- [x] Contributors/workflow and GitHub Issue/PR templates
- [x] Connect local folder to GitHub repository and push `main`
**Deliverable:** team can clone, understand, and coordinate.

## Phase 1 — Database
- [x] Organization, platform users, memberships, projects
- [x] Environments, SDK keys, and application users
- [x] Feature flags (typed values, prerequisites, staleness), groups, memberships
- [x] Rollout history, evaluation records, telemetry events, audit logs, and webhooks
- [x] Ordered SQL migrations (`000`–`003`), synthetic ShopSphere seed script, and constraint verification queries
- [x] ER diagram, composite-FK tenant isolation, indexes, and constraints
**Deliverable:** reproducible schema and seed data.

## Phase 2 — Backend foundation
- [ ] Node + TypeScript + Express
- [ ] Config validation and MySQL connection pool
- [ ] Logging, error handling, request validation
- [ ] Health/readiness endpoints, API versioning
- [ ] OpenAPI documentation and unit tests
**Deliverable:** running API connected to MySQL.

## Phase 3 — Authentication and tenancy
- [ ] Registration/invitation and login
- [ ] Password hashing and token strategy
- [ ] RBAC and organization-scoped access
- [ ] Auth/security tests
**Deliverable:** protected tenant-safe API.

## Phase 4 — Flag management
- [ ] Project/environment APIs & env-to-env promotion diff
- [ ] Flag CRUD, typed values, prerequisites, and staleness settings
- [ ] Enable/disable kill switch with audit reason prompt
- [ ] Configuration versioning and audit history
- [ ] Scoped SDK keys & safe key rotation
**Deliverable:** flags managed through API.

## Phase 5 — Evaluation engine
- [ ] Evaluation contract and fallback behavior
- [ ] Attribute targeting operators & prerequisite checks
- [ ] Group targeting
- [ ] Deterministic percentage rollout
- [ ] Rule precedence, reason codes, and debug evaluation playground API
- [ ] Edge-case tests
**Deliverable:** repeatable evaluation decisions.

## Phase 6 — JavaScript/TypeScript SDK
- [ ] Initialization and context
- [ ] Typed evaluation API
- [ ] Config fetching and local evaluation
- [ ] Fallback behavior and examples
**Deliverable:** app integrates flags through SDK.

## Phase 7 — Distribution and caching
- [ ] Redis cache and version strategy
- [ ] Config snapshots and polling
- [ ] SSE updates if appropriate
- [ ] Invalidation, outage, stale-cache behavior
- [ ] Consistency and latency tests
**Deliverable:** efficient config propagation.

## Phase 8 — Telemetry & Org/Project Intelligence
- [ ] Evaluation event contract
- [ ] Separate evaluation, exposure, conversion
- [ ] Ingestion endpoint & SDK metadata tracking
- [ ] Org & Project Insights APIs (active users, flag adoption, stale flag detector, team velocity, app traffic)
- [ ] Kafka producer/consumer & production change webhooks
- [ ] Aggregation, storage, retention
- [ ] Failure/backpressure handling
**Deliverable:** reliable event pipeline and analytics APIs.

## Phase 9 — Frontend
- [ ] React/TypeScript setup
- [ ] Auth and organization/project navigation
- [ ] Organization Intelligence & Project App Health dashboards
- [ ] Environments, flag list/detail, and env promotion diff
- [ ] Flag creation/editing, targeting & rollout UI, kill-switch confirmation
- [ ] Debug evaluation playground (rule & hash bucket trace)
- [ ] Groups, funnel charts, audit history
- [ ] UI tests
**Deliverable:** platform managed through dashboard.

## Phase 10 — Monitoring and release safety
- [ ] Metrics, logs, tracing
- [ ] Evaluation latency/error monitoring
- [ ] Rollout health indicators and alerts
- [ ] Rollback recommendations
- [ ] Automated rollback only with safeguards/tests
**Deliverable:** visibility into release health.

## Phase 11 — Testing and deployment
- [ ] Unit, integration, E2E, load tests
- [ ] Dockerfiles and Compose
- [ ] CI pipeline
- [ ] Deployment and secret management
- [ ] Security review and migration process
- [ ] Documentation/demo
**Deliverable:** reproducible, deployable end-to-end project.

## Definition of done
Merged code, relevant tests passing, documentation updated, and feature demonstrable. Planned infrastructure is not claimed as implemented.
