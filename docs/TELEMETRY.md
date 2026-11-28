# Telemetry and Analytics Design

## 1. Event Separation Principle

The platform strictly separates three event types so analytics never conflate backend flag checks with real user behavior:

1. **Evaluation Event (`EVALUATION`)**
   - Recorded when the evaluation plane decides a flag value for a context.
   - Fields: `eventId`, `organizationId`, `environmentId`, `flagId`, `flagKey`, `userId`, `evaluatedValue`, `reason`, `configVersion`, `timestamp`.
2. **Exposure Event (`EXPOSURE`)**
   - Recorded by the application/SDK only when the user actually sees or enters the gated experience (e.g., renders the new checkout UI).
   - Fields: `eventId`, `organizationId`, `environmentId`, `flagKey`, `userId`, `variantOrValue`, `sessionId`, `timestamp`.
3. **Conversion Event (`CONVERSION`)**
   - Recorded when a downstream business outcome happens (e.g., `checkout_completed`, `purchase_value`).
   - Fields: `eventId`, `organizationId`, `environmentId`, `eventName`, `userId`, `sessionId`, `properties` (validated JSON), `timestamp`.

## 2. Reliability & Deduplication

- Every event carries a client-generated `eventId` (UUID) for idempotent ingestion / deduplication on retries.
- Telemetry ingestion must be non-blocking for flag evaluation: if telemetry persistence or Kafka is temporarily degraded, flag evaluation still succeeds.

## 3. Metric Definitions

- **Total Evaluations**: Raw count of `EVALUATION` events (not unique users).
- **Enabled Evaluation Rate**: `enabled_evaluations / total_evaluations`.
- **Unique Exposed Users**: Distinct `userId` values with an `EXPOSURE` event for a flag/value.
- **Cohort Conversion Rate**: `(distinct exposed users who triggered conversion event) / (distinct exposed users)` for the same `flagKey` and evaluated value within the selected time window.
