---
name: nextjs-master
description: Build production Next.js applications with App Router, server components, caching, and optimal rendering strategies. Covers routing, data fetching, authentication, and deployment.
license: MIT
compatibility: opencode
metadata:
  audience: developers
  workflow: frontend
  category: frontend
---

# Next.js Master

## What I Do

I help build production-ready Next.js applications using modern App Router patterns, server components, and optimal caching strategies. I ensure apps are fast, SEO-friendly, and maintainable.

## App Router

### File Conventions
```
app/
├── layout.tsx          # Shared UI wrapper
├── page.tsx            # Route UI
├── loading.tsx         # Loading UI (Suspense boundary)
├── error.tsx           # Error boundary
├── not-found.tsx       # 404 UI
├── template.tsx        # Re-mounted layout on navigation
├── route.ts            # API route (Route Handler)
├── globals.css         # Global styles
├── (auth)/             # Route group (no URL segment)
│   ├── login/page.tsx
│   └── register/page.tsx
├── @modal/             # Parallel route (slot)
│   └── default.tsx
└── [...slug]/          # Catch-all route
    └── page.tsx
```

### Layout
```tsx
export default function RootLayout({
  children,
  sidebar,
}: {
  children: React.ReactNode;
  sidebar: React.ReactNode;
}) {
  return (
    <html lang="en">
      <body>
        <nav>...</nav>
        <div className="layout">
          <aside>{sidebar}</aside>
          <main>{children}</main>
        </div>
      </body>
    </html>
  );
}
```

### Loading and Error States
```tsx
// loading.tsx — automatic Suspense boundary
export default function Loading() {
  return <div className="skeleton">Loading...</div>;
}

// error.tsx — automatic error boundary
'use client';
export default function Error({
  error,
  reset,
}: {
  error: Error & { digest?: string };
  reset: () => void;
}) {
  return (
    <div>
      <h2>Something went wrong!</h2>
      <button onClick={reset}>Try again</button>
    </div>
  );
}
```

## Server vs Client Components

### Server Components (Default)
```tsx
// Server Component — can use async, access DB directly
export default async function Page() {
  const users = await db.user.findMany();
  return <UserList users={users} />;
}
```

### Client Components
```tsx
'use client';
import { useState } from 'react';

export default function Counter() {
  const [count, setCount] = useState(0);
  return <button onClick={() => setCount(c => c + 1)}>{count}</button>;
}
```

### Composition Pattern
```tsx
// Server Component
import { ClientCounter } from './ClientCounter';

export default function Page() {
  const data = await fetchData();
  // Client component receives server data as props
  return (
    <div>
      <h1>{data.title}</h1>
      <ClientCounter initialCount={data.count} />
    </div>
  );
}
```

## Data Fetching

### Server Component Fetching
```tsx
// Automatic caching and deduplication
async function getUser(id: string) {
  const res = await fetch(`https://api.example.com/users/${id}`, {
    next: { revalidate: 3600 }, // Cache for 1 hour
  });
  return res.json();
}

export default async function Page({ params }: { params: { id: string } }) {
  const user = await getUser(params.id);
  return <UserProfile user={user} />;
}
```

### Cache Tags (On-Demand Revalidation)
```tsx
// Fetch with tags
async function getProducts() {
  const res = await fetch('https://api.example.com/products', {
    next: { tags: ['products'] },
  });
  return res.json();
}

// Revalidate in Server Action or Route Handler
import { revalidateTag } from 'next/cache';

async function updateProduct(data: FormData) {
  await db.product.update(data);
  revalidateTag('products');
}

// Or by path
import { revalidatePath } from 'next/cache';
revalidatePath('/products');
revalidatePath('/products/[id]', 'page');
```

### Server Actions
```tsx
'use client';
import { createProduct } from './actions';

export function ProductForm() {
  return (
    <form action={createProduct}>
      <input name="name" required />
      <input name="price" type="number" required />
      <button type="submit">Create</button>
    </form>
  );
}

// actions.ts
'use server';
import { revalidatePath } from 'next/cache';

export async function createProduct(formData: FormData) {
  const name = formData.get('name') as string;
  const price = Number(formData.get('price'));
  
  await db.product.create({ data: { name, price } });
  revalidatePath('/products');
}
```

## Caching Layers

### Cache Hierarchy
1. **Full Route Cache** — Static RSC payload (build time)
2. **Data Cache** — Fetch results (persistent across deployments)
3. **Router Cache** — Client-side RSC payload (session)
4. **Request Memoization** — Dedupe within single request

### Controlling Cache
```tsx
// Opt out of caching (dynamic)
export const dynamic = 'force-dynamic';

// Opt into static rendering
export const dynamic = 'force-static';

// Control segment config
export const revalidate = 3600; // ISR — revalidate every hour

// Route segment config
export const dynamicParams = true;
export const dynamic = 'auto';
```

## Routing

### Dynamic Routes
```tsx
// app/products/[id]/page.tsx
export default async function Page({ params }: { params: { id: string } }) {
  const product = await getProduct(params.id);
  return <ProductDetail product={product} />;
}

// Generate static params
export async function generateStaticParams() {
  const products = await db.product.findMany({ select: { id: true } });
  return products.map((p) => ({ id: p.id.toString() }));
}

// Catch-all: app/docs/[...slug]/page.tsx
export default function Page({ params }: { params: { slug: string[] } }) {
  return <DocContent slug={params.slug} />;
}

// Optional catch-all: app/docs/[[...slug]]/page.tsx
export default function Page({ params }: { params?: { slug: string[] } }) {
  const slug = params?.slug ?? ['index'];
  return <DocContent slug={slug} />;
}
```

### Parallel Routes
```tsx
// app/@analytics/page.tsx
export default function AnalyticsPage() {
  return <AnalyticsDashboard />;
}

// app/@team/page.tsx
export default function TeamPage() {
  return <TeamMembers />;
}

// app/layout.tsx
export default function Layout({
  analytics,
  team,
}: {
  analytics: React.ReactNode;
  team: React.ReactNode;
}) {
  return (
    <>
      {analytics}
      {team}
    </>
  );
}
```

### Intercepting Routes
```tsx
// app/@modal/(.)photo/[id]/page.tsx
// Intercepts /photo/123 when navigated from current layout
export default function PhotoModal({ params }: { params: { id: string } }) {
  return <Modal><Photo id={params.id} /></Modal>;
}

// app/@modal/default.tsx
export default function Default() {
  return null;
}
```

## API Routes (Route Handlers)
```tsx
// app/api/users/route.ts
import { NextRequest, NextResponse } from 'next/server';

export async function GET(request: NextRequest) {
  const searchParams = request.nextUrl.searchParams;
  const page = Number(searchParams.get('page')) || 1;
  
  const users = await db.user.findMany({
    skip: (page - 1) * 20,
    take: 20,
  });
  
  return NextResponse.json(users);
}

export async function POST(request: NextRequest) {
  const body = await request.json();
  const user = await db.user.create({ data: body });
  return NextResponse.json(user, { status: 201 });
}

// Route config
export const dynamic = 'force-dynamic';
```

## Middleware
```tsx
// middleware.ts (root level)
import { NextResponse } from 'next/server';
import type { NextRequest } from 'next/server';

export function middleware(request: NextRequest) {
  const token = request.cookies.get('token');
  
  if (!token && request.nextUrl.pathname.startsWith('/dashboard')) {
    return NextResponse.redirect(new URL('/login', request.url));
  }
  
  // Add custom header
  const response = NextResponse.next();
  response.headers.set('x-user-id', token?.value ?? '');
  return response;
}

export const config = {
  matcher: ['/dashboard/:path*', '/api/:path*'],
};
```

## Image Optimization
```tsx
import Image from 'next/image';

// Optimized image with automatic format detection
<Image
  src="/hero.jpg"
  alt="Hero banner"
  width={1200}
  height={600}
  priority  // Above the fold — preload
/>

// Responsive
<Image
  src="/product.jpg"
  alt="Product"
  width={800}
  height={600}
  sizes="(max-width: 768px) 100vw, (max-width: 1200px) 50vw, 33vw"
  placeholder="blur"
  blurDataURL="/product-blur.jpg"
/>

// Remote images — configure in next.config.ts
const nextConfig = {
  images: {
    remotePatterns: [
      { protocol: 'https', hostname: 'cdn.example.com' },
    ],
  },
};
```

## Authentication
```tsx
// middleware.ts — route protection
import { NextResponse } from 'next/server';
import type { NextRequest } from 'next/server';
import { verifyToken } from './lib/auth';

export function middleware(request: NextRequest) {
  const token = request.cookies.get('auth-token');
  
  if (!token) {
    const url = new URL('/login', request.url);
    url.searchParams.set('callbackUrl', request.nextUrl.pathname);
    return NextResponse.redirect(url);
  }
  
  try {
    const payload = verifyToken(token.value);
    const requestHeaders = new Headers(request.headers);
    requestHeaders.set('x-user-id', payload.sub);
    return NextResponse.next({ request: { headers: requestHeaders } });
  } catch {
    return NextResponse.redirect(new URL('/login', request.url));
  }
}

export const config = {
  matcher: ['/dashboard/:path*', '/settings/:path*'],
};
```

## Performance

### Streaming
```tsx
// Stream slow data without blocking the page
export default function Page() {
  return (
    <>
      <Header />
      <Suspense fallback={<ProductSkeleton />}>
        <Products />  {/* Fetches and streams */}
      </Suspense>
      <Footer />
    </>
  );
}

async function Products() {
  const products = await getProducts(); // Slow query
  return <ProductGrid products={products} />;
}
```

### Bundle Optimization
```tsx
// Dynamic imports for client components
import dynamic from 'next/dynamic';

const HeavyChart = dynamic(() => import('./HeavyChart'), {
  loading: () => <ChartSkeleton />,
  ssr: false, // Don't render on server
});

// Use only when needed
'use client';
import { useState } from 'react';
```

## Deployment

### Environment Variables
```env
# .env.local (not committed)
DATABASE_URL=postgresql://...
AUTH_SECRET=your-secret-key

# .env (committed, non-secret)
NEXT_PUBLIC_API_URL=https://api.example.com
```

### Build Config
```ts
// next.config.ts
const nextConfig = {
  output: 'standalone', // For Docker deployment
  experimental: {
    serverActions: { bodySizeLimit: '2mb' },
  },
  logging: {
    fetches: { fullUrl: true },
  },
};

export default nextConfig;
```

## When to Use Me

Use this skill when:
- Building Next.js applications with App Router
- Implementing server and client components
- Setting up data fetching and caching
- Creating API route handlers
- Configuring middleware for auth
- Optimizing images and fonts
- Implementing streaming and Suspense
- Deploying Next.js apps

## Quality Checklist

- [ ] Server components by default, client only when needed
- [ ] Data fetching in server components with cache tags
- [ ] Loading states via loading.tsx files
- [ ] Error boundaries via error.tsx files
- [ ] generateStaticParams for known routes
- [ ] Images use next/image with proper dimensions
- [ ] Middleware protects authenticated routes
- [ ] Server actions handle errors gracefully
- [ ] Environment variables properly scoped (NEXT_PUBLIC_ vs server-only)
- [ ] Dynamic imports for heavy client components
- [ ] next.config.ts optimized for production
