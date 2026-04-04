# Security Rules

These security rules MUST be followed for all code. Security is not optional.

## Input Validation

- NEVER trust user input — validate ALL input on the server
- Use allowlists, not blocklists
- Validate type, length, format, and range
- Sanitize output even after input validation (defense in depth)
- Use parameterized queries — NEVER string concatenation for SQL
- Validate Content-Type of file uploads
- Enforce file size limits

## Authentication & Authorization

- Never store passwords in plain text — use bcrypt (cost 12+) or argon2id
- Use httpOnly, secure, sameSite cookies for auth tokens — NEVER localStorage
- Implement rate limiting on auth endpoints
- Verify authorization on EVERY request — never trust client-side checks
- Use least privilege principle — deny by default
- Implement account lockout after failed attempts
- Use short-lived access tokens (15min-1hr) with refresh tokens

## Data Protection

- Encrypt sensitive data at rest (AES-256-GCM)
- Use HTTPS everywhere — enforce with HSTS
- Never log sensitive data (passwords, tokens, PII, credit cards)
- Use environment variables for secrets — never hardcode
- Remove secrets from git history if accidentally committed
- Use secret scanning tools (git-secrets, trufflehog)

## Web Security

- Set security headers (CSP, X-Content-Type-Options, X-Frame-Options)
- Implement CSRF protection for state-changing requests
- Escape all user output — never use innerHTML with user data
- Set SameSite cookie attribute
- Use Subresource Integrity (SRI) for CDN resources
- Configure CORS restrictively — never use wildcard with credentials

## Dependencies

- Regularly audit dependencies for known vulnerabilities
- Pin dependency versions
- Remove unused dependencies
- Review new dependencies before adding
- Enable automated security updates (Dependabot, Renovate)

## Never Do

- eval() or equivalent with user input
- SQL string concatenation
- Storing secrets in code or config files
- Disabling SSL/TLS verification
- Using crypto functions from untrusted sources
- Exposing stack traces in production error responses
- Using MD5 or SHA1 for security purposes
