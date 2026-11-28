# Architecture

## Control plane
Dashboard and management API for organizations, users, projects, environments, flags, targeting, rollouts, and audit history.

## Evaluation plane
SDK/evaluation path receives a flag key and context, loads config, applies disabled/default logic, targeting and rollout, and returns value plus reason. Caching/local evaluation will be introduced incrementally.

## Telemetry plane
Evaluation events, exposure events (feature actually shown/used), and conversion/business events are distinct. Telemetry should be asynchronous and not block flag evaluation.

## Planned flow
1. Admin changes flag.
2. API validates authorization/config.
3. MySQL persists state/version/history.
4. Distribution/cache propagates configuration.
5. SDK evaluates using context.
6. Events are emitted asynchronously.
7. Processing/aggregation powers dashboards.

## Data ownership
- MySQL: authoritative core state.
- Redis: cache, not source of truth.
- Kafka: event transport in later phase.
- Analytics storage: chosen based on workload and retention.

## Tenant isolation
Scope every tenant-owned resource by organization. Validate tenant ownership in API queries and authorization. Composite foreign keys help but do not replace auth checks.

## Reliability
Explicit evaluation fallbacks; telemetry must not block evaluations; cache outage/staleness behavior is tested; config is versioned; percentage rollout is deterministic.
