# Database Schema

Primary database: MySQL 8 / InnoDB.

| Table | Purpose |
|---|---|
| ORGANIZATION | Tenant/company |
| PLATFORM_USER | Dashboard identities and roles |
| PROJECT | Application |
| ENVIRONMENT | Project environment |
| APPLICATION_USER | End-user context and attributes |
| FEATURE_FLAG | Flag configuration |
| USER_GROUP | Targeting group |
| GROUP_MEMBERSHIP | User/group relationship |
| FLAG_ROLLOUT | Rollout history |
| FLAG_EVALUATION | Evaluation records |

## Relationships
Organization 1:N platform users, projects, app users, groups. Project 1:N environments. Environment 1:N flags. Groups M:N app users via GROUP_MEMBERSHIP. Flags 1:N rollout and evaluation records.

## Notes
- PLATFORM_USER and APPLICATION_USER are different identities.
- JSON attributes/rules require backend validation.
- Rollout history is not automatically the authoritative current configuration.
- Evaluation does not prove exposure or conversion.
- Tenant consistency requires scoped queries and authorization, plus composite constraints where practical.
- Add indexes based on query paths and explain plans.

## Migrations
Convert the initial manually created Workbench schema into ordered migrations. A fresh database must be reproducible from migrations and seed scripts.
