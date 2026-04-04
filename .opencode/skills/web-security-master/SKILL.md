---
name: web-security-master
description: Secure web applications against common vulnerabilities. Covers CSP, XSS, CSRF, secure cookies, SRI, HTTPS, security headers, and client-side storage security.
license: MIT
compatibility: opencode
metadata:
  audience: developers
  workflow: frontend
  category: frontend
---

# Web Security Master

## What I Do

I help secure web applications against common client-side and server-side vulnerabilities. I implement defense-in-depth strategies using security headers, proper authentication, and secure coding practices.

## Content Security Policy (CSP)

### Directives
```http
# Strict CSP — recommended starting point
Content-Security-Policy: 
  default-src 'self';
  script-src 'self';
  style-src 'self' 'unsafe-inline';
  img-src 'self' data: https:;
  font-src 'self';
  connect-src 'self' https://api.example.com;
  frame-src 'none';
  object-src 'none';
  base-uri 'self';
  form-action 'self';
  frame-ancestors 'none';
  upgrade-insecure-requests;
  block-all-mixed-content;
```

### Directive Reference
| Directive | Controls | Recommended |
|-----------|----------|-------------|
| `default-src` | Fallback for other directives | `'self'` |
| `script-src` | JavaScript sources | `'self'` + nonces |
| `style-src` | CSS sources | `'self'` (avoid `unsafe-inline`) |
| `img-src` | Image sources | `'self' data: https:` |
| `connect-src` | Fetch/XHR/WebSocket | `'self'` + API domains |
| `font-src` | Font sources | `'self'` |
| `frame-src` | iframe sources | `'none'` |
| `object-src` | `<object>`, `<embed>` | `'none'` |
| `base-uri` | `<base>` URL | `'self'` |
| `form-action` | Form submission targets | `'self'` |
| `frame-ancestors` | Who can embed you | `'none'` |

### Nonce-Based Scripts
```html
<!-- Server generates random nonce per request -->
<script nonce="random-nonce-per-request">
  // Inline script allowed
</script>

<!-- CSP header -->
Content-Security-Policy: script-src 'self' 'nonce-random-nonce-per-request'
```

### Report-Only Mode
```http
# Test CSP without blocking
Content-Security-Policy-Report-Only: 
  default-src 'self';
  script-src 'self';
  report-uri /csp-report;
  report-to csp-endpoint;

{
  "group": "csp-endpoint",
  "max_age": 10886400,
  "endpoints": [{ "url": "/csp-report" }]
}
```

## XSS Prevention

### Types of XSS
```
Stored XSS:
  Malicious script stored in database, served to all users
  Example: Malicious comment on blog post

Reflected XSS:
  Malicious script reflected from URL parameter
  Example: <script> in search query

DOM-based XSS:
  Malicious script executed via DOM manipulation
  Example: document.location.hash used unsafely
```

### Prevention
```tsx
// React auto-escapes by default — safe
<div>{userInput}</div>

// Dangerous — bypasses escaping
<div dangerouslySetInnerHTML={{ __html: userInput }} />

// If you must use HTML, sanitize first
import DOMPurify from 'dompurify';

const safeHTML = DOMPurify.sanitize(userInput, {
  ALLOWED_TAGS: ['b', 'i', 'em', 'strong', 'a', 'p', 'ul', 'li'],
  ALLOWED_ATTR: ['href', 'title'],
  ALLOWED_URI_REGEXP: /^(?:(?:(?:f|ht)tps?|mailto|tel|callto|cid|xmpp):|[^a-z]|[a-z+.\-]+(?:[^a-z+.\-:]|$))/i,
});

<div dangerouslySetInnerHTML={{ __html: safeHTML }} />

// Never use user input in these contexts:
// - JavaScript: eval(), setTimeout(string), new Function()
// - HTML attributes: onclick, onerror, href="javascript:..."
// - URL construction: window.location = userInput
// - CSS: style property with user input
```

### URL Context XSS
```tsx
// Bad — javascript: protocol
<a href={userInput}>Link</a>
// userInput = "javascript:alert(1)"

// Good — validate URL protocol
function isValidUrl(url: string): boolean {
  try {
    const parsed = new URL(url);
    return ['http:', 'https:', 'mailto:'].includes(parsed.protocol);
  } catch {
    return false;
  }
}

{isValidUrl(userInput) && <a href={userInput}>Link</a>}
```

## CSRF Protection

### CSRF Token Pattern
```tsx
// Server generates token, stores in session
const csrfToken = generateToken();
res.cookie('csrf-token', csrfToken, { httpOnly: true, sameSite: 'strict' });
res.render('form', { csrfToken });

// Form includes token
<form method="POST" action="/api/update">
  <input type="hidden" name="_csrf" value="{{ csrfToken }}">
  <button type="submit">Update</button>
</form>

// Server validates
app.post('/api/update', (req, res) => {
  const token = req.body._csrf || req.headers['x-csrf-token'];
  if (!token || token !== req.session.csrfToken) {
    return res.status(403).json({ error: 'Invalid CSRF token' });
  }
  // Process request
});
```

### Double Submit Cookie
```typescript
// Set cookie
res.cookie('XSRF-TOKEN', csrfToken, { httpOnly: false, sameSite: 'strict' });

// Client reads cookie and sends as header
const token = document.cookie.match(/XSRF-TOKEN=([^;]+)/)?.[1];
fetch('/api/update', {
  method: 'POST',
  headers: { 'X-XSRF-TOKEN': token },
});

// Server compares cookie value with header value
// If they match — same origin (attacker can't read cookies)
```

### SameSite Cookie Attribute
```
SameSite=Strict:
  Cookie sent only for same-site requests
  Not sent when following links from other sites
  Best security, may break legitimate cross-site flows

SameSite=Lax (default in modern browsers):
  Cookie sent for top-level navigation (clicking links)
  Not sent for cross-site POST requests, iframes, images
  Good balance of security and usability

SameSite=None:
  Cookie sent for all requests
  Must be used with Secure flag
  Required for cross-site functionality
```

## Secure Cookies

### Configuration
```typescript
res.cookie('session', token, {
  httpOnly: true,       // Not accessible via JavaScript
  secure: true,         // HTTPS only
  sameSite: 'strict',   // CSRF protection
  maxAge: 24 * 60 * 60 * 1000, // 24 hours
  path: '/',
  domain: 'example.com', // Explicit domain
});

// For partitioned cookies (CHIPS)
res.cookie('session', token, {
  httpOnly: true,
  secure: true,
  sameSite: 'none',
  partitioned: true,    // Third-party context isolation
});
```

## Subresource Integrity (SRI)

### Implementation
```html
<!-- Generate hash: echo -n "file content" | shasum -a 384 | awk '{print $1}' | xxd -r -p | base64 -->
<script 
  src="https://cdn.example.com/library.min.js"
  integrity="sha384-oqVuAfXRKap7fdgcCY5uykM6+R9GqQ8K/uxy9rx7HNQlGYl1kPzQho1wx4JwY8wC"
  crossorigin="anonymous"
></script>

<link 
  rel="stylesheet"
  href="https://cdn.example.com/styles.css"
  integrity="sha384-..."
  crossorigin="anonymous"
>

<!-- Always use crossorigin for cross-origin resources -->
<!-- Use SHA-384 minimum (SHA-256 is acceptable but weaker) -->
```

## HTTPS/TLS

### Configuration
```nginx
server {
  listen 443 ssl http2;
  server_name example.com;

  ssl_certificate /path/to/fullchain.pem;
  ssl_certificate_key /path/to/privkey.pem;
  
  ssl_protocols TLSv1.2 TLSv1.3;
  ssl_ciphers ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256;
  ssl_prefer_server_ciphers off;
  ssl_session_timeout 1d;
  ssl_session_cache shared:SSL:10m;
  
  # HSTS — force HTTPS
  add_header Strict-Transport-Security "max-age=63072000; includeSubDomains; preload" always;
  
  # Redirect HTTP to HTTPS
  listen 80;
  return 301 https://$host$request_uri;
}
```

### Certificate Management
```
Let's Encrypt:
  - Free, automated
  - 90-day validity
  - Auto-renewal with certbot
  - Supports wildcard certificates

Certificate Pinning:
  - Embed certificate hash in app
  - Prevents MITM with rogue certificates
  - Use with caution — can break if cert rotates
  - Consider HPKP alternatives (Expect-CT header)
```

## Security Headers

### Complete Set
```typescript
import helmet from 'helmet';

app.use(helmet({
  contentSecurityPolicy: {
    directives: {
      defaultSrc: ["'self'"],
      scriptSrc: ["'self'"],
      styleSrc: ["'self'", "'unsafe-inline'"],
      imgSrc: ["'self'", 'data:', 'https:'],
      connectSrc: ["'self'", 'https://api.example.com'],
      fontSrc: ["'self'"],
      objectSrc: ["'none'"],
      frameSrc: ["'none'"],
      baseUri: ["'self'"],
      formAction: ["'self'"],
    },
  },
  crossOriginEmbedderPolicy: true,
  crossOriginOpenerPolicy: { policy: 'same-origin' },
  crossOriginResourcePolicy: { policy: 'same-origin' },
  dnsPrefetchControl: { allow: false },
  frameguard: { action: 'deny' },
  hsts: { maxAge: 31536000, includeSubDomains: true, preload: true },
  ieNoOpen: true,
  noSniff: true,
  referrerPolicy: { policy: 'strict-origin-when-cross-origin' },
  xssFilter: true,
}));

// Additional headers
app.use((req, res, next) => {
  res.removeHeader('X-Powered-By');
  res.setHeader('Permissions-Policy', 'camera=(), microphone=(), geolocation=()');
  next();
});
```

### Header Reference
| Header | Value | Purpose |
|--------|-------|---------|
| `X-Content-Type-Options` | `nosniff` | Prevent MIME sniffing |
| `X-Frame-Options` | `DENY` | Prevent clickjacking |
| `Strict-Transport-Security` | `max-age=31536000; includeSubDomains` | Force HTTPS |
| `X-XSS-Protection` | `0` | Disable legacy XSS filter (use CSP) |
| `Referrer-Policy` | `strict-origin-when-cross-origin` | Control referrer info |
| `Permissions-Policy` | `camera=(), microphone=()` | Restrict browser features |
| `Cross-Origin-Opener-Policy` | `same-origin` | Isolate browsing context |
| `Cross-Origin-Resource-Policy` | `same-origin` | Restrict resource loading |

## Clickjacking Protection

```html
<!-- CSP frame-ancestors (modern approach) -->
Content-Security-Policy: frame-ancestors 'none'

<!-- X-Frame-Options (legacy support) -->
X-Frame-Options: DENY

<!-- Allow specific domains -->
Content-Security-Policy: frame-ancestors 'self' https://trusted.example.com
X-Frame-Options: SAMEORIGIN

<!-- JavaScript defense (fallback) -->
<script>
  if (window.top !== window.self) {
    window.top.location = window.self.location;
  }
</script>
```

## Client-Side Storage Security

### Storage Comparison
| Storage | Capacity | Persistence | XSS Risk | Use Case |
|---------|----------|-------------|----------|----------|
| localStorage | ~5MB | Until cleared | High | Non-sensitive prefs |
| sessionStorage | ~5MB | Tab close | High | Temporary data |
| Cookies | 4KB | Configurable | Low (httpOnly) | Auth tokens |
| IndexedDB | Unlimited | Until cleared | High | Large offline data |

### Rules
```
NEVER store in localStorage/sessionStorage:
  - Authentication tokens (use httpOnly cookies)
  - Passwords
  - PII (personally identifiable information)
  - Credit card numbers
  - Session identifiers

OK to store:
  - UI preferences (theme, language)
  - Cached non-sensitive data
  - Shopping cart contents
  - Draft form data
```

### Secure Token Storage
```typescript
// Bad — accessible to any JavaScript
localStorage.setItem('token', jwtToken);

// Good — httpOnly cookie, not accessible via JS
res.cookie('auth-token', jwtToken, {
  httpOnly: true,
  secure: true,
  sameSite: 'strict',
  maxAge: 3600000, // 1 hour
});

// For refresh tokens — longer-lived httpOnly cookie
res.cookie('refresh-token', refreshToken, {
  httpOnly: true,
  secure: true,
  sameSite: 'strict',
  maxAge: 7 * 24 * 60 * 60 * 1000, // 7 days
  path: '/auth/refresh', // Scoped path
});
```

## Input Validation (Client + Server)

### Client-Side (UX, NOT Security)
```tsx
// Client validation improves UX but is NOT security
<form onSubmit={handleSubmit}>
  <input 
    type="email" 
    required 
    minLength={5} 
    maxLength={100}
    pattern="[^@]+@[^@]+\.[^@]+"
  />
  <input 
    type="text" 
    required 
    minLength={1} 
    maxLength={100}
  />
  <button type="submit">Submit</button>
</form>
```

### Server-Side (MUST Have)
```typescript
import { z } from 'zod';

const userSchema = z.object({
  email: z.string().email().max(100),
  name: z.string().min(1).max(100).regex(/^[a-zA-Z\s-']+$/),
  bio: z.string().max(500).optional(),
  role: z.enum(['user', 'admin']).default('user'),
});

app.post('/users', async (req, res) => {
  const result = userSchema.safeParse(req.body);
  if (!result.success) {
    return res.status(400).json({ errors: result.error.errors });
  }
  
  // Additional: escape output when rendering
  const safeName = escapeHtml(result.data.name);
  // ...
});

function escapeHtml(str: string): string {
  return str
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;')
    .replace(/'/g, '&#x27;');
}
```

## When to Use Me

Use this skill when:
- Configuring security headers
- Implementing CSP policies
- Preventing XSS attacks
- Setting up CSRF protection
- Configuring secure cookies
- Implementing SRI for CDN resources
- Setting up HTTPS/TLS
- Auditing client-side storage
- Validating and sanitizing user input

## Quality Checklist

- [ ] CSP header configured with restrictive directives
- [ ] All user output escaped or sanitized
- [ ] Auth tokens in httpOnly cookies, not localStorage
- [ ] CSRF protection for state-changing requests
- [ ] Cookies have httpOnly, secure, sameSite flags
- [ ] SRI hashes for all third-party scripts/styles
- [ ] HTTPS enforced with HSTS
- [ ] Security headers configured (helmet or equivalent)
- [ ] X-Frame-Options or CSP frame-ancestors set
- [ ] Permissions-Policy restricts unnecessary features
- [ ] Server-side validation on all inputs
- [ ] No sensitive data in client-side storage
- [ ] X-Powered-By header removed
