# ADR 001: Initial technology stack

Status: Accepted for initial implementation; revisit if requirements change.

- React + TypeScript + Vite for dashboard.
- Node.js + TypeScript + Express for API.
- MySQL 8 for authoritative relational state.
- Redis cache later.
- Kafka event streaming later.
- JavaScript/TypeScript SDK first.
- Docker and GitHub Actions for reproducible development and CI.

Rationale: familiar, widely supported stack and clear component boundaries. Introduce distributed components only after the basic system works and can be measured.
