# Database

Contains ordered MySQL 8 migrations, verification queries, and local development seed data.

## Directory Layout
- `migrations/` — Ordered SQL schema migrations (`000_*.sql`, `001_*.sql`, ...).
- `seeds/` — Repeatable local development synthetic data (`001_demo_shopsphere_seed.sql`).
- `schema/` — Constraint and analytics verification queries (`verify_constraints.sql`).

## Fresh Setup Commands (MySQL 8 CLI)

1. Create the local database:
```sql
CREATE DATABASE IF NOT EXISTS feature_flag_platform
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;
```

2. Run migrations in order (PowerShell example):
```powershell
Get-ChildItem .\database\migrations\*.sql | Sort-Object Name | ForEach-Object {
  Get-Content $_.FullName -Raw | mysql -u root -p feature_flag_platform
}
```

3. Load local seed data:
```powershell
Get-Content .\database\seeds\001_demo_shopsphere_seed.sql -Raw | mysql -u root -p feature_flag_platform
```

4. Run verification queries:
```powershell
Get-Content .\database\schema\verify_constraints.sql -Raw | mysql -u root -p feature_flag_platform
```
