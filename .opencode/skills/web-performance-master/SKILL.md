---
name: web-performance-master
description: Optimize web application performance for Core Web Vitals and user experience. Covers loading, rendering, bundle optimization, CDN, caching, and measurement.
license: MIT
compatibility: opencode
metadata:
  audience: developers
  workflow: frontend
  category: frontend
---

# Web Performance Master

## What I Do

I help optimize web application performance to deliver fast, smooth user experiences. I focus on Core Web Vitals, loading optimization, and measurement-driven improvements.

## Core Web Vitals

### Metrics and Targets
| Metric | What It Measures | Good | Needs Improvement | Poor |
|--------|-----------------|------|-------------------|------|
| LCP (Largest Contentful Paint) | Loading performance | ≤ 2.5s | 2.5-4s | > 4s |
| INP (Interaction to Next Paint) | Responsiveness | ≤ 200ms | 200-500ms | > 500ms |
| CLS (Cumulative Layout Shift) | Visual stability | ≤ 0.1 | 0.1-0.25 | > 0.25 |

### Optimizing LCP
```html
<!-- Preload critical resources -->
<link rel="preload" href="/fonts/inter-var.woff2" as="font" crossorigin>
<link rel="preload" href="/hero.webp" as="image">

<!-- Optimize LCP element -->
<img src="/hero.webp" alt="Hero" width="1200" height="600" fetchpriority="high">

<!-- Server-side render above-the-fold content -->
<!-- Don't lazy-load LCP element -->
<!-- Use CDN for fast delivery -->
<!-- Compress images: WebP/AVIF -->
```

### Optimizing INP
```tsx
// Break up long tasks
// Bad: Single 200ms task
function processLargeDataset(data: Data[]) {
  data.forEach(item => heavyComputation(item));
}

// Good: Split into chunks with scheduler
function processLargeDataset(data: Data[]) {
  let index = 0;
  function processChunk() {
    const end = Math.min(index + 100, data.length);
    for (; index < end; index++) {
      heavyComputation(data[index]);
    }
    if (index < data.length) {
      scheduler.postTask(processChunk, { priority: 'background' });
    }
  }
  processChunk();
}

// Debounce expensive operations
const handleScroll = debounce(() => {
  updateVisibleItems();
}, 16); // ~1 frame at 60fps

// Use requestIdleCallback for non-critical work
requestIdleCallback(() => {
  sendAnalytics();
  preloadNextPage();
});
```

### Optimizing CLS
```css
/* Always set dimensions for images and iframes */
img, video, iframe {
  width: 100%;
  height: auto;
  aspect-ratio: 16 / 9;
}

/* Reserve space for dynamic content */
.ad-slot {
  min-height: 250px;
  background: #f0f0f0;
}

/* Avoid inserting content above existing content */
.banner {
  position: fixed;
  bottom: 0;
  /* Not top: 0 — pushes content down */
}

/* Use transform instead of properties that trigger layout */
.dropdown {
  transform: translateY(-100%);
  transition: transform 0.3s ease;
}
```

## Loading Performance

### Resource Hints
```html
<!-- Preconnect to origins -->
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://cdn.example.com" crossorigin>

<!-- DNS prefetch (lower priority than preconnect) -->
<link rel="dns-prefetch" href="https://analytics.example.com">

<!-- Preload critical resources -->
<link rel="preload" href="/critical.css" as="style">
<link rel="preload" href="/app.js" as="script">

<!-- Prefetch next likely page -->
<link rel="prefetch" href="/next-page.html" as="document">

<!-- Prerender entire page -->
<link rel="prerender" href="/next-page.html">
```

### Script Loading
```html
<!-- Default: blocks parsing -->
<script src="app.js"></script>

<!-- Defer: downloads in parallel, executes after HTML parsed (maintains order) -->
<script src="app.js" defer></script>

<!-- Async: downloads in parallel, executes as soon as ready (no order) -->
<script src="analytics.js" async></script>

<!-- Module: deferred by default -->
<script type="module" src="app.js"></script>
```

### Lazy Loading
```tsx
// Images below fold
<img src="photo.jpg" loading="lazy" alt="Description" width="800" height="600">

// Iframes
<iframe src="https://youtube.com/embed/..." loading="lazy"></iframe>

// Components (React)
const HeavyChart = lazy(() => import('./HeavyChart'));

// Routes (React Router)
const Dashboard = lazy(() => import('./Dashboard'));

// Intersection Observer for custom lazy loading
const observer = new IntersectionObserver((entries) => {
  entries.forEach(entry => {
    if (entry.isIntersecting) {
      entry.target.src = entry.target.dataset.src;
      observer.unobserve(entry.target);
    }
  });
}, { rootMargin: '200px' });
```

## Bundle Optimization

### Analysis
```bash
# Analyze bundle
npx webpack-bundle-analyzer dist/stats.json
npx vite-bundle-visualizer

# Check bundle size limits
ls -lh dist/assets/*.js
```

### Tree Shaking
```javascript
// package.json
{
  "sideEffects": false  // or list files with side effects
}

// Use named imports (not default) for better tree shaking
import { debounce, throttle } from 'lodash-es';  // Good
import _ from 'lodash';  // Bad — imports everything

// Use ESM modules, not CommonJS
// import from 'lodash-es' not 'lodash'
```

### Code Splitting Strategies
```tsx
// Route-level splitting
const routes = {
  '/': lazy(() => import('./pages/Home')),
  '/dashboard': lazy(() => import('./pages/Dashboard')),
  '/settings': lazy(() => import('./pages/Settings')),
};

// Component-level splitting
const Modal = lazy(() => import('./Modal'));
const Chart = lazy(() => import('./Chart'));

// Vendor splitting (Webpack)
optimization: {
  splitChunks: {
    chunks: 'all',
    cacheGroups: {
      vendor: {
        test: /[\\/]node_modules[\\/]/,
        name: 'vendors',
        chunks: 'all',
      },
    },
  },
}
```

### Bundle Budget
```
Total JavaScript: < 200KB gzipped (initial load)
Total CSS: < 50KB gzipped
Single chunk: < 50KB gzipped
Total page weight: < 1MB (mobile-first)

Monitor with:
- Lighthouse performance budget
- Webpack bundle size limits
- CI checks on PR
```

## Image Optimization

### Format Selection
```
AVIF: Best compression, modern browsers (use first)
WebP: Good compression, wide support (fallback for AVIF)
JPEG: Photos, legacy support
PNG: Images with transparency, graphics
SVG: Icons, logos, illustrations
```

### Responsive Images
```html
<picture>
  <source srcset="hero.avif" type="image/avif">
  <source srcset="hero.webp" type="image/webp">
  <img
    src="hero.jpg"
    alt="Hero banner"
    width="1200"
    height="600"
    sizes="(max-width: 768px) 100vw, (max-width: 1200px) 50vw, 800px"
    srcset="
      hero-400.jpg 400w,
      hero-800.jpg 800w,
      hero-1200.jpg 1200w,
      hero-1600.jpg 1600w
    "
  >
</picture>
```

### Optimization Pipeline
```
Original → Resize to max display size → Compress (WebP/AVIF) → CDN
                                                        ↓
                                                Quality: 80-85%
                                                        ↓
                                                Strip metadata
                                                        ↓
                                                Progressive encoding
```

## Font Optimization

### Best Practices
```css
/* Use variable fonts (single file, all weights) */
@font-face {
  font-family: 'Inter';
  src: url('/fonts/inter-var.woff2') format('woff2');
  font-weight: 100 900;
  font-display: swap;
  font-style: normal;
}

/* Preload critical font */
<link rel="preload" href="/fonts/inter-var.woff2" as="font" crossorigin>

/* Subset fonts */
/* Only include characters you need */
/* Latin, Latin-extended — not Cyrillic, Greek if not needed */

/* System font stack as fallback */
font-family: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
```

## Caching Strategies

### HTTP Cache Headers
```
Static assets (hashed filenames):
  Cache-Control: public, max-age=31536000, immutable

HTML pages:
  Cache-Control: no-cache  (revalidate with ETag)

API responses:
  Cache-Control: private, max-age=60  (or appropriate TTL)

Dynamic content:
  Cache-Control: no-store  (never cache)
```

### Service Worker
```javascript
// Workbox — caching strategies
import { registerRoute } from 'workbox-routing';
import { CacheFirst, NetworkFirst, StaleWhileRevalidate } from 'workbox-strategies';

// Images: cache first
registerRoute(
  ({ request }) => request.destination === 'image',
  new CacheFirst({
    cacheName: 'images',
    plugins: [
      new ExpirationPlugin({ maxEntries: 50, maxAgeSeconds: 30 * 24 * 60 * 60 }),
    ],
  })
);

// API: stale while revalidate
registerRoute(
  ({ url }) => url.pathname.startsWith('/api/'),
  new StaleWhileRevalidate({
    cacheName: 'api-cache',
    plugins: [
      new ExpirationPlugin({ maxEntries: 100, maxAgeSeconds: 5 * 60 }),
    ],
  })
);

// HTML: network first
registerRoute(
  ({ request }) => request.destination === 'document',
  new NetworkFirst({
    cacheName: 'pages',
    networkTimeoutSeconds: 3,
  })
);
```

## CDN Configuration

### Best Practices
```
- Enable Brotli compression (better than gzip)
- Set appropriate Cache-Control headers
- Enable HTTP/2 or HTTP/3
- Configure edge caching rules
- Use image optimization at edge (Cloudflare, imgix)
- Enable automatic HTTPS redirect
- Configure custom error pages
- Set up WAF rules
- Use cache tags for selective invalidation
```

## Network Optimization

### HTTP/2 and HTTP/3
```
HTTP/2:
- Multiplexing (multiple requests over single connection)
- Header compression (HPACK)
- Server push
- No need for domain sharding

HTTP/3 (QUIC):
- UDP-based (no TCP head-of-line blocking)
- Faster connection establishment
- Better on unreliable networks
- Built-in encryption
```

### Connection Optimization
```html
<!-- Preconnect to critical origins -->
<link rel="preconnect" href="https://api.example.com">

<!-- Prefetch DNS -->
<link rel="dns-prefetch" href="https://analytics.example.com">

<!-- Reduce third-party impact -->
<!-- Load analytics async -->
<!-- Lazy-load chat widgets -->
<!-- Use facades for embedded content -->
```

## Measurement

### Lab Tools
```
Lighthouse:
  - Performance score
  - Core Web Vitals
  - Opportunities and diagnostics
  - Run in Chrome DevTools or CI

WebPageTest:
  - Real device testing
  - Filmstrip view
  - Waterfall chart
  - Multiple locations and connections

Chrome DevTools:
  - Performance panel (flame chart)
  - Network panel (waterfall)
  - Lighthouse panel
  - Coverage panel (unused code)
```

### Real User Monitoring (RUM)
```javascript
// Web Vitals library
import { onLCP, onINP, onCLS } from 'web-vitals';

function sendToAnalytics(metric) {
  // Send to your analytics
  navigator.sendBeacon('/analytics', JSON.stringify(metric));
}

onLCP(sendToAnalytics);
onINP(sendToAnalytics);
onCLS(sendToAnalytics);

// Chrome User Timing API
performance.mark('app-start');
// ... app initialization ...
performance.mark('app-ready');
performance.measure('app-init', 'app-start', 'app-ready');
```

### Performance Budget in CI
```yaml
# GitHub Actions
- name: Lighthouse CI
  uses: treosh/lighthouse-ci-action@v11
  with:
    urls: |
      http://localhost:3000/
      http://localhost:3000/products
    budgetPath: ./budget.json
    uploadArtifacts: true

# budget.json
{
  "ci": {
    "collect": {
      "settings": { "preset": "desktop" }
    }
  },
  "budgets": [
    {
      "path": "/*",
      "resourceSizes": [{ "resourceType": "script", "budget": 200 }],
      "timings": [{ "metric": "interactive", "budget": 3000 }]
    }
  ]
}
```

## When to Use Me

Use this skill when:
- Optimizing Core Web Vitals scores
- Reducing bundle size
- Implementing code splitting
- Optimizing images and fonts
- Configuring CDN and caching
- Setting up performance budgets
- Measuring real user performance
- Debugging slow page loads

## Quality Checklist

- [ ] LCP ≤ 2.5s for all key pages
- [ ] INP ≤ 200ms for all interactions
- [ ] CLS ≤ 0.1 (no unexpected layout shifts)
- [ ] Images use modern formats (AVIF/WebP)
- [ ] Images have width/height attributes
- [ ] Critical CSS inlined
- [ ] JavaScript split into chunks < 50KB gzipped
- [ ] Third-party scripts loaded async or deferred
- [ ] Fonts use font-display: swap
- [ ] Static assets have immutable cache headers
- [ ] Performance budget enforced in CI
- [ ] RUM tracking Core Web Vitals
