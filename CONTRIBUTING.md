# Contributing

Coordinate work through GitHub Issues and Pull Requests.

## Before starting
1. Read README and ROADMAP.
2. Read architecture and the relevant module documentation.
3. Check Issues/project board for existing work.
4. Comment on an issue to claim it and agree on scope.

## Branches
- `feature/<name>`
- `fix/<name>`
- `docs/<name>`
- `refactor/<name>`
- `test/<name>`

## Workflow
1. Pull latest `main`.
2. Create a branch.
3. Make a focused change.
4. Run tests/checks.
5. Commit, push, and open a PR to `main`.
6. Request review and address feedback.
7. Merge after review/checks pass.

## Commit examples
- `feat: add flag creation endpoint`
- `fix: enforce organization isolation`
- `docs: update database setup`
- `test: cover percentage rollout`

## PR checklist
- Explain problem and solution; link issue.
- List tests run.
- Update docs if behavior/setup changes.
- Include screenshots for UI changes when useful.
- Avoid unrelated changes.

## Rules
- Never commit secrets, `.env`, credentials, or real customer data.
- Do not work directly on `main`.
- Coordinate before editing shared files.
- Do not add dependencies without justification.
- Only claim features that are implemented and tested.
