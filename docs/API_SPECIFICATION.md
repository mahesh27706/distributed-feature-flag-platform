# API Specification (planned)

Prefix: `/api/v1`. This is an outline, not implemented endpoints.

## Health
- `GET /health`
- `GET /ready`

## Auth
- `POST /auth/register` or invitation flow (decision pending)
- `POST /auth/login`
- `POST /auth/refresh` if refresh tokens adopted
- `POST /auth/logout`

## Projects/environments
- `GET /organizations`
- `GET /organizations/:orgId/projects`
- `POST /projects`
- `GET /projects/:projectId`
- `POST /projects/:projectId/environments`

## Flags
- `GET /environments/:environmentId/flags`
- `POST /environments/:environmentId/flags`
- `GET /flags/:flagId`
- `PATCH /flags/:flagId`
- `DELETE /flags/:flagId` (consider archive)
- `POST /flags/:flagId/evaluate` (debug endpoint)

## Groups
- `POST /groups`
- `GET /groups`
- `POST /groups/:groupId/members`
- `DELETE /groups/:groupId/members/:appUserId`

## Rollouts/events
- `POST /flags/:flagId/rollouts`
- `POST /events/evaluations`
- `POST /events/exposures`

Endpoints need auth, tenant scope, validation, response/error schemas before implementation.
