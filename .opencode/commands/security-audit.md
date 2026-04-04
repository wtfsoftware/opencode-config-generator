---
description: Perform a security audit on the selected code
agent: build
---
Perform a security audit on the selected code and project.

Check for:
1. **OWASP Top 10** — injection, broken auth, sensitive data exposure, XSS, CSRF, SSRF, insecure deserialization
2. **Code-specific vulnerabilities** — hardcoded secrets, unvalidated input, missing CSRF tokens, insecure CORS, path traversal, timing attacks
3. **Dependency security** — known CVEs, outdated packages

For each finding:
- Severity: critical / high / medium / low / info
- File and line number
- Description of the vulnerability
- Exploitation scenario
- Concrete fix with code example

Start with critical and high severity issues.
