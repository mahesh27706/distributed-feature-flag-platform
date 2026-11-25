# Security

- Never commit secrets, tokens, credentials, `.env`, or production data.
- Hash passwords with a suitable password hashing algorithm; never store plaintext.
- Validate and authorize every request.
- Enforce tenant scope for tenant-owned resources.
- Use least-privilege database/service accounts.
- Validate attributes and targeting-rule JSON.
- Avoid logging credentials, tokens, or sensitive attributes.
- Use TLS in deployed environments.
- Never expose server credentials in browser code.
- Report vulnerabilities privately to maintainers.
