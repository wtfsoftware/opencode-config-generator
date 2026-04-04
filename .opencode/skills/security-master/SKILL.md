---
name: security-master
description: Implement secure applications following OWASP guidelines and industry best practices. Covers authentication, authorization, input validation, common vulnerabilities, and security hardening.
license: MIT
compatibility: opencode
metadata:
  audience: developers
  workflow: fullstack
  category: backend
---

# Security Master

## What I Do

I help build secure applications by identifying vulnerabilities, implementing proper authentication and authorization, and following security best practices throughout the development lifecycle.

## OWASP Top 10 (2024)

### A01: Broken Access Control
**Problem**: Users can act outside their intended permissions.

**Prevention**
```typescript
// Middleware for role-based access
function requireRole(...roles: string[]) {
  return (req: Request, res: Response, next: NextFunction) => {
    if (!req.user || !roles.includes(req.user.role)) {
      return res.status(403).json({ error: 'Forbidden' });
    }
    next();
  };
}

// Usage
app.delete('/users/:id', requireRole('admin'), deleteUser);

// Always verify on server — never trust client-side checks
// Use deny-by-default approach
```

### A02: Cryptographic Failures
**Problem**: Sensitive data exposed due to weak or missing encryption.

**Prevention**
```typescript
// Password hashing — use bcrypt or argon2
import bcrypt from 'bcrypt';

const saltRounds = 12;
const hash = await bcrypt.hash(password, saltRounds);
const isValid = await bcrypt.compare(password, hash);

// Encrypt sensitive data at rest
import { createCipheriv, randomBytes } from 'crypto';

function encrypt(text: string, key: Buffer): { iv: string; encrypted: string } {
  const iv = randomBytes(16);
  const cipher = createCipheriv('aes-256-gcm', key, iv);
  const encrypted = Buffer.concat([cipher.update(text, 'utf8'), cipher.final()]);
  return { iv: iv.toString('hex'), encrypted: encrypted.toString('hex') };
}

// Use HTTPS everywhere
// Set HSTS header
app.use(helmet.hsts({ maxAge: 31536000, includeSubDomains: true }));
```

**Rules**
- Never store passwords in plain text
- Use bcrypt (cost 12+) or argon2id for passwords
- Use AES-256-GCM for data encryption
- Never roll your own crypto
- Rotate encryption keys regularly

### A03: Injection
**Problem**: Untrusted data sent to interpreter as part of command or query.

**SQL Injection Prevention**
```typescript
// Bad — vulnerable to SQL injection
const query = `SELECT * FROM users WHERE email = '${email}'`;

// Good — parameterized queries
const query = 'SELECT * FROM users WHERE email = $1';
const result = await db.query(query, [email]);

// Good — ORM with parameterization
const user = await db.user.findUnique({ where: { email } });
```

**XSS Prevention**
```typescript
// Frameworks (React, Vue, Angular) auto-escape by default
// Dangerous: dangerouslySetInnerHTML, v-html, innerHTML

// If you must use HTML, sanitize it first
import DOMPurify from 'dompurify';

const safeHTML = DOMPurify.sanitize(userProvidedHTML, {
  ALLOWED_TAGS: ['b', 'i', 'em', 'strong', 'a'],
  ALLOWED_ATTR: ['href'],
});

// Set Content Security Policy
app.use(helmet.contentSecurityPolicy({
  directives: {
    defaultSrc: ["'self'"],
    scriptSrc: ["'self'"],
    styleSrc: ["'self'", "'unsafe-inline'"],
    imgSrc: ["'self'", 'data:', 'https:'],
  },
}));
```

**Command Injection Prevention**
```typescript
// Bad
exec(`convert ${filename} output.png`);

// Good — use array form, no shell interpretation
import { execFile } from 'child_process';
execFile('convert', [filename, 'output.png']);

// Better — use native library instead of shell command
```

### A04: Insecure Design
**Problem**: Missing or ineffective control design.

**Prevention**
- Threat modeling during design phase
- Secure by default design patterns
- Defense in depth (multiple layers)
- Rate limiting and throttling
- Account lockout after failed attempts

### A05: Security Misconfiguration
**Problem**: Insecure default configurations or incomplete configurations.

**Server Hardening**
```typescript
import helmet from 'helmet';

app.use(helmet()); // Sets various security headers

// Security headers set by helmet:
// Content-Security-Policy
// X-Content-Type-Options: nosniff
// X-Frame-Options: SAMEORIGIN
// X-XSS-Protection: 0 (deprecated, use CSP instead)
// Strict-Transport-Security
// X-DNS-Prefetch-Control
// X-Download-Options
// X-Permitted-Cross-Domain-Policies
// Referrer-Policy

// Additional headers
app.use((req, res, next) => {
  res.setHeader('X-Content-Type-Options', 'nosniff');
  res.setHeader('Cache-Control', 'no-store');
  res.removeHeader('X-Powered-By'); // Don't reveal tech stack
  next();
});
```

### A06: Vulnerable and Outdated Components
**Problem**: Using components with known vulnerabilities.

**Prevention**
```bash
# Audit dependencies regularly
npm audit
npm audit fix

# Use automated tools
npm install -g npm-audit-resolver
npx depcheck

# GitHub Dependabot
# .github/dependabot.yml
# version: 2
# updates:
#   - package-ecosystem: "npm"
#     directory: "/"
#     schedule:
#       interval: "weekly"
```

### A07: Identification and Authentication Failures
**Problem**: Weak authentication implementation.

See Authentication section below.

### A08: Software and Data Integrity Failures
**Problem**: Code and infrastructure not protected against integrity violations.

**Prevention**
- Use CI/CD with proper access controls
- Verify digital signatures
- Use Subresource Integrity (SRI) for external scripts
- Immutable infrastructure
- Code signing for releases

```html
<!-- SRI for external scripts -->
<script src="https://cdn.example.com/lib.js"
  integrity="sha384-..."
  crossorigin="anonymous"></script>
```

### A09: Security Logging and Monitoring Failures
**Problem**: Insufficient logging and monitoring.

**What to Log**
- Failed login attempts
- Access control failures
- Input validation failures
- Server errors
- Sensitive operations (password changes, payments)

**What NOT to Log**
- Passwords
- Session tokens
- Credit card numbers
- PII (personally identifiable information)
- Full request bodies with sensitive data

```typescript
import winston from 'winston';

const logger = winston.createLogger({
  level: 'info',
  format: winston.format.json(),
  transports: [
    new winston.transports.File({ filename: 'security.log' }),
  ],
});

// Log security events
logger.warn('Failed login attempt', {
  ip: req.ip,
  username: req.body.username, // NOT the password
  timestamp: new Date().toISOString(),
});
```

### A10: Server-Side Request Forgery (SSRF)
**Problem**: Server makes requests to unintended locations.

**Prevention**
```typescript
// Bad — user controls URL
const response = await fetch(req.body.url);

// Good — whitelist allowed domains
const ALLOWED_DOMAINS = ['api.example.com', 'cdn.example.com'];
const url = new URL(req.body.url);

if (!ALLOWED_DOMAINS.includes(url.hostname)) {
  throw new Error('Domain not allowed');
}

// Block internal IPs
const blocked = ['localhost', '127.0.0.1', '169.254.169.254', '0.0.0.0'];
if (blocked.includes(url.hostname)) {
  throw new Error('Access denied');
}

const response = await fetch(url.toString());
```

## Authentication

### JWT (JSON Web Tokens)
```typescript
import jwt from 'jsonwebtoken';

// Create token
const token = jwt.sign(
  { userId: user.id, role: user.role },
  process.env.JWT_SECRET!,
  { expiresIn: '15m', issuer: 'myapp' }
);

// Verify token
try {
  const payload = jwt.verify(token, process.env.JWT_SECRET!, {
    issuer: 'myapp',
    algorithms: ['HS256'],
  });
} catch (err) {
  // Token invalid or expired
}

// JWT Best Practices:
// - Short-lived access tokens (15min-1hr)
// - Use refresh tokens for renewal
// - Store in httpOnly cookies, NOT localStorage
// - Always verify signature and expiration
// - Include minimal claims
```

### Refresh Token Pattern
```typescript
// Login
app.post('/login', async (req, res) => {
  const user = await authenticate(req.body);
  const accessToken = createAccessToken(user);
  const refreshToken = createRefreshToken(user);

  // Store refresh token hash in database
  await storeRefreshToken(user.id, hashToken(refreshToken));

  // Access token in memory (client-side)
  res.json({ accessToken });

  // Refresh token in httpOnly cookie
  res.cookie('refreshToken', refreshToken, {
    httpOnly: true,
    secure: true,
    sameSite: 'strict',
    maxAge: 7 * 24 * 60 * 60 * 1000, // 7 days
  });
});

// Refresh
app.post('/token/refresh', async (req, res) => {
  const token = req.cookies.refreshToken;
  if (!token) return res.status(401).json({ error: 'No refresh token' });

  const payload = verifyRefreshToken(token);
  const storedHash = await getRefreshToken(payload.userId);

  if (!storedHash || !compareToken(token, storedHash)) {
    // Token stolen — revoke all tokens for this user
    await revokeAllUserTokens(payload.userId);
    return res.status(401).json({ error: 'Invalid refresh token' });
  }

  const newAccessToken = createAccessToken(payload);
  res.json({ accessToken });
});
```

### Session-Based Auth
```typescript
import session from 'express-session';
import connectRedis from 'connect-redis';

app.use(session({
  store: new connectRedis({ client: redisClient }),
  secret: process.env.SESSION_SECRET!,
  resave: false,
  saveUninitialized: false,
  cookie: {
    httpOnly: true,
    secure: true,
    sameSite: 'lax',
    maxAge: 24 * 60 * 60 * 1000, // 24 hours
  },
}));
```

### OAuth2 / OIDC
```typescript
// Authorization Code Flow with PKCE (recommended for SPAs)
// 1. Generate code verifier and challenge
const codeVerifier = crypto.randomBytes(32).toString('base64url');
const codeChallenge = crypto.createHash('sha256').update(codeVerifier).digest('base64url');

// 2. Redirect to authorization server
const authUrl = `https://auth.example.com/authorize?` +
  `response_type=code&` +
  `client_id=${clientId}&` +
  `redirect_uri=${redirectUri}&` +
  `code_challenge=${codeChallenge}&` +
  `code_challenge_method=S256&` +
  `scope=openid profile email`;

// 3. Exchange code for tokens (server-side)
const tokens = await fetch('https://auth.example.com/token', {
  method: 'POST',
  body: new URLSearchParams({
    grant_type: 'authorization_code',
    code,
    redirect_uri: redirectUri,
    client_id: clientId,
    code_verifier: codeVerifier,
  }),
});
```

## Authorization

### RBAC (Role-Based Access Control)
```typescript
const permissions: Record<string, string[]> = {
  admin: ['user:read', 'user:write', 'user:delete', 'settings:read', 'settings:write'],
  editor: ['user:read', 'user:write', 'settings:read'],
  viewer: ['user:read', 'settings:read'],
};

function hasPermission(role: string, permission: string): boolean {
  return permissions[role]?.includes(permission) ?? false;
}
```

### ABAC (Attribute-Based Access Control)
```typescript
interface AccessRequest {
  subject: { id: string; role: string; department: string };
  action: string;
  resource: { type: string; ownerId: string; department: string };
}

function checkAccess(req: AccessRequest): boolean {
  // Owners can always access their resources
  if (req.subject.id === req.resource.ownerId) return true;

  // Same department can read
  if (req.subject.department === req.resource.department && req.action === 'read') return true;

  // Admins can do anything
  if (req.subject.role === 'admin') return true;

  return false;
}
```

## Input Validation

### Server-Side Validation (Always Required)
```typescript
import { z } from 'zod';

const createUserSchema = z.object({
  name: z.string().min(1).max(100),
  email: z.string().email(),
  password: z.string().min(8).max(128),
  role: z.enum(['user', 'editor', 'admin']).default('user'),
  age: z.number().int().min(0).max(150).optional(),
});

app.post('/users', async (req, res) => {
  const result = createUserSchema.safeParse(req.body);
  if (!result.success) {
    return res.status(400).json({
      errors: result.error.errors.map(e => ({
        field: e.path.join('.'),
        message: e.message,
      })),
    });
  }

  const { name, email, password, role } = result.data;
  // Proceed with creation...
});
```

### Validation Rules
- Validate ALL input — query params, body, headers, cookies
- Whitelist allowed values, don't blacklist bad ones
- Enforce length limits on all strings
- Validate content type of uploads
- Sanitize output even after input validation

## CORS Configuration

```typescript
import cors from 'cors';

app.use(cors({
  origin: process.env.NODE_ENV === 'production'
    ? ['https://app.example.com', 'https://admin.example.com']
    : 'http://localhost:3000',
  credentials: true,
  methods: ['GET', 'POST', 'PUT', 'DELETE'],
  allowedHeaders: ['Content-Type', 'Authorization'],
  maxAge: 86400, // Cache preflight for 24 hours
}));

// NEVER use wildcard with credentials
// app.use(cors({ origin: '*', credentials: true })); // DANGEROUS
```

## CSRF Protection

```typescript
import csurf from 'csurf';

// For session-based auth
const csrfProtection = csurf({ cookie: true });

app.get('/form', csrfProtection, (req, res) => {
  res.render('form', { csrfToken: req.csrfToken() });
});

app.post('/submit', csrfProtection, (req, res) => {
  // CSRF token validated automatically
});

// For API with JWT in httpOnly cookie, CSRF protection is needed
// For JWT in Authorization header, CSRF is not applicable
```

## Rate Limiting

```typescript
import rateLimit from 'express-rate-limit';

// General API rate limit
const apiLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 100, // 100 requests per window
  message: { error: 'Too many requests, please try again later' },
  standardHeaders: true,
  legacyHeaders: false,
});

// Stricter limit for auth endpoints
const authLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 5, // 5 login attempts per 15 minutes
  skipSuccessfulRequests: true,
});

app.use('/api/', apiLimiter);
app.use('/api/auth/login', authLimiter);
```

## Security Headers Summary

```typescript
import helmet from 'helmet';

app.use(helmet({
  contentSecurityPolicy: {
    directives: {
      defaultSrc: ["'self'"],
      scriptSrc: ["'self'"],
      styleSrc: ["'self'", "'unsafe-inline'"],
      imgSrc: ["'self'", 'data:', 'https:'],
      connectSrc: ["'self'"],
      fontSrc: ["'self'"],
      objectSrc: ["'none'"],
      frameSrc: ["'none'"],
    },
  },
  crossOriginEmbedderPolicy: true,
  crossOriginOpenerPolicy: true,
  crossOriginResourcePolicy: { policy: 'same-origin' },
  dnsPrefetchControl: { allow: false },
  frameguard: { action: 'deny' },
  hsts: { maxAge: 31536000, includeSubDomains: true, preload: true },
  ieNoOpen: true,
  noSniff: true,
  referrerPolicy: { policy: 'strict-origin-when-cross-origin' },
  xssFilter: true,
}));
```

## Dependency Security

```bash
# Regular audit
npm audit --audit-level=high

# Auto-fix
npm audit fix

# Check for outdated packages
npm outdated

# Use lockfile
npm ci  # In CI/CD, uses package-lock.json exactly

# Snyk for advanced scanning
npx snyk test
```

## When to Use Me

Use this skill when:
- Implementing authentication/authorization
- Setting up security headers
- Validating user input
- Configuring CORS
- Implementing rate limiting
- Auditing code for vulnerabilities
- Setting up dependency scanning
- Creating security middleware
- Handling sensitive data
- Implementing encryption

## Quality Checklist

- [ ] All user input validated and sanitized
- [ ] Passwords hashed with bcrypt (cost 12+) or argon2id
- [ ] JWT stored in httpOnly cookies, not localStorage
- [ ] HTTPS enforced with HSTS
- [ ] Security headers configured (helmet)
- [ ] CORS restricted to specific origins
- [ ] Rate limiting on auth and public endpoints
- [ ] SQL parameterized queries used
- [ ] Dependencies audited regularly
- [ ] Security events logged
- [ ] No secrets in code or logs
- [ ] CSRF protection for session-based auth
- [ ] Access control verified on every request
- [ ] Error messages don't leak sensitive information
