# Development Setup

## Prerequisites
Git, Node.js LTS/npm, MySQL 8. VS Code recommended. Redis/Kafka/Docker are added later.

## Clone
```bash
git clone <repository-url>
cd distributed-feature-flag-platform
```

## Database
Create local database:
```sql
CREATE DATABASE feature_flag_platform;
```
Apply migrations in order; seed data is local development only.

## Environment
Copy `.env.example` to `.env` and fill local values. Never commit `.env`.

Backend/frontend setup instructions will be added when packages are initialized.

## Troubleshooting
- Confirm MySQL is running and port/credentials are correct.
- Check `node -v` and `npm -v`.
- Do not share secrets in issues/screenshots.
