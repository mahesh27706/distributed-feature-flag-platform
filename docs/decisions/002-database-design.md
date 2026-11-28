# ADR 002: Relational core and JSON attributes

Status: Accepted for initial implementation.

Use MySQL for core entities and relationships; JSON for variable application-user attributes and flexible targeting configuration.

Consequences:
- Backend validates JSON structure and supported operators.
- JSON does not replace relational keys.
- Add indexes/generated columns after query patterns are known.
- MongoDB is not required merely because MySQL supports JSON; revisit separate event storage if analytics workload warrants it.
