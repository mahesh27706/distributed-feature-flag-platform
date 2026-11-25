# Distributed Feature Flag Platform

A multi-tenant feature flag management and telemetry platform designed to decouple software deployment from feature release.

## Goals
- Manage flags across projects and environments.
- Support typed values, attribute/group targeting, and deterministic percentage rollouts.
- Provide a management API and developer SDK.
- Distribute configuration efficiently using caching and versioning.
- Collect evaluation/exposure telemetry and monitor release health.

## Planned stack
React + TypeScript + Vite; Node.js + TypeScript + Express; MySQL 8; Redis; Kafka (later phase); JavaScript/TypeScript SDK; Docker; GitHub Actions.

## Architecture
- Control plane: dashboard, management API, auth, configuration writes.
- Evaluation plane: SDK/evaluation path for fast decisions.
- Telemetry plane: event ingestion, processing, analytics.

## Status
Planned technologies/features are not considered implemented until merged and tested.

See [Roadmap](ROADMAP.md), [Architecture](docs/ARCHITECTURE.md), [Development Setup](docs/DEVELOPMENT_SETUP.md), and [Contributing](CONTRIBUTING.md).
