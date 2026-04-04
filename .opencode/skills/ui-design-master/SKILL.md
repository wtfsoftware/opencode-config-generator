---
name: ui-design-master
description: Create stunning, production-ready UIs with modern design principles, accessibility standards, and UX best practices. Covers layout, typography, color theory, responsive design, animations, and component architecture.
license: MIT
compatibility: opencode
metadata:
  audience: developers
  workflow: frontend
  category: frontend
---

# UI Design Master

## What I Do

I help create beautiful, functional, and accessible user interfaces following industry best practices. I apply proven design principles, modern CSS techniques, and UX patterns to deliver polished interfaces.

## Core Design Principles

### Visual Hierarchy
- Use size, color, contrast, and spacing to guide the eye
- Establish clear content priority through typographic scale
- Apply the "squint test" - key elements should stand out when squinting
- Use the 60-30-10 color rule (60% dominant, 30% secondary, 10% accent)

### Layout Systems
- Implement CSS Grid for 2D layouts, Flexbox for 1D
- Use consistent spacing scale (4px/8px base unit system)
- Apply the rule of thirds and golden ratio for visual balance
- Maintain consistent alignment - never center and left-align in the same section without reason

### Typography
- Limit to 2 font families max (one for headings, one for body)
- Use modular scale for font sizes (1.125 or 1.25 ratio)
- Maintain optimal line length (45-75 characters)
- Set line-height: 1.5 for body, 1.2-1.3 for headings
- Use font-weight variation for hierarchy, not just size

### Color Systems
- Build a semantic color palette (primary, secondary, success, warning, error, neutral)
- Ensure WCAG AA contrast (4.5:1 for normal text, 3:1 for large text)
- Use HSL for programmatic color generation
- Support dark mode with inverted lightness values
- Never use pure black (#000) - use very dark grays instead

### Spacing & Rhythm
- Use consistent spacing scale: 4, 8, 12, 16, 24, 32, 48, 64, 96, 128
- Apply vertical rhythm - related elements closer, unrelated further apart
- Use padding proportional to element size
- Maintain consistent margins around similar elements

### Micro-interactions & Animation
- Duration: 150-300ms for micro-interactions
- Use ease-out for entering, ease-in for exiting
- Transform and opacity only (GPU-accelerated)
- Respect prefers-reduced-motion
- Add hover, focus, and active states to all interactive elements

## Accessibility (a11y) Requirements

### Must Always Include
- Semantic HTML (header, nav, main, section, article, aside, footer)
- ARIA labels where semantic HTML isn't sufficient
- Keyboard navigation for all interactive elements
- Visible focus indicators (never outline: none without replacement)
- Alt text for meaningful images, empty alt for decorative
- Form labels (visible or aria-label)
- Error messages linked to inputs with aria-describedby
- Skip navigation link for multi-page sites

### Testing Checklist
- Tab through entire interface
- Test with screen reader (VoiceOver/NVDA)
- Verify color contrast ratios
- Check at 200% zoom
- Test without CSS
- Verify focus order matches visual order

## Responsive Design Strategy

### Mobile-First Approach
- Design for mobile first, enhance for larger screens
- Breakpoints: 640px (sm), 768px (md), 1024px (lg), 1280px (xl), 1536px (2xl)
- Use clamp() for fluid typography and spacing
- Touch targets minimum 44x44px
- Test on actual devices, not just browser dev tools

### Responsive Patterns
- Stack columns → side by side → multi-column
- Hamburger menu → horizontal nav
- Hide secondary info → reveal on larger screens
- Single column cards → grid layouts

## Component Architecture

### Design System Foundations
- Create reusable component primitives (Button, Input, Card, Modal)
- Implement composition over configuration
- Use CSS custom properties for theming
- Document component variants and states
- Build with progressive enhancement

### State Management for UI
- Default, hover, focus, active, disabled, loading, error, empty
- Skeleton screens for loading states
- Graceful error boundaries
- Empty states with helpful messaging and CTAs

## Modern CSS Techniques

### Essential Patterns
```css
/* Fluid typography */
font-size: clamp(1rem, 2vw + 0.5rem, 2rem);

/* Aspect ratio container */
aspect-ratio: 16 / 9;

/* Scroll snap */
scroll-snap-type: x mandatory;

/* Container queries */
@container (min-width: 400px) { ... }

/* Layered styling */
@layer base, components, utilities;

/* Modern color functions */
color: oklch(60% 0.2 250);
```

### Performance
- Use CSS containment for complex components
- Prefer CSS animations over JS
- Implement content-visibility for off-screen content
- Optimize images with srcset and sizes
- Use font-display: swap for web fonts

## CSS Architecture

### Methodologies Overview

**BEM (Block Element Modifier)**
- Best for: Large teams, long-term projects
- Structure: `.block__element--modifier`
- Pros: Predictable, self-documenting, no conflicts
- Cons: Verbose class names

**Utility-First (Tailwind)**
- Best for: Rapid prototyping, design systems
- Structure: Compose utilities directly in HTML
- Pros: Fast development, consistent design tokens, small CSS output
- Cons: HTML can become cluttered, learning curve

**CSS Modules**
- Best for: Component-based frameworks (React, Vue)
- Structure: Scoped class names per file
- Pros: Local scope, no naming conflicts, works with preprocessors
- Cons: Build step required, harder to override

**CSS-in-JS (Styled Components, Emotion)**
- Best for: React apps with dynamic theming
- Structure: Styles defined alongside components
- Pros: Dynamic props, automatic critical CSS, theme support
- Cons: Runtime overhead, harder to debug, lock-in

### When to Choose What
- Small project / prototype → Utility-First or plain CSS
- Enterprise app with many developers → BEM or CSS Modules
- React-heavy app with theming → CSS-in-JS or CSS Modules
- Design system → Utility-First with custom tokens

### Organization Best Practices
```
styles/
├── base/           # Resets, variables, mixins
│   ├── _reset.css
│   ├── _variables.css
│   └── _mixins.css
├── components/     # Component-specific styles
│   ├── _button.css
│   ├── _card.css
│   └── _modal.css
├── layouts/        # Page-level layouts
│   ├── _header.css
│   ├── _sidebar.css
│   └── _footer.css
└── utilities/      # Helper classes
    ├── _spacing.css
    └── _visibility.css
```

### CSS Custom Properties Strategy
```css
:root {
  /* Colors */
  --color-primary: hsl(220 90% 56%);
  --color-primary-light: hsl(220 90% 66%);
  --color-primary-dark: hsl(220 90% 46%);

  /* Spacing */
  --space-xs: 0.25rem;
  --space-sm: 0.5rem;
  --space-md: 1rem;
  --space-lg: 1.5rem;
  --space-xl: 2rem;
  --space-2xl: 3rem;

  /* Typography */
  --font-sans: 'Inter', system-ui, sans-serif;
  --font-mono: 'Fira Code', monospace;
  --text-sm: 0.875rem;
  --text-base: 1rem;
  --text-lg: 1.125rem;
  --text-xl: 1.25rem;
  --text-2xl: 1.5rem;

  /* Borders */
  --radius-sm: 4px;
  --radius-md: 8px;
  --radius-lg: 12px;
  --radius-full: 9999px;

  /* Shadows */
  --shadow-sm: 0 1px 2px rgba(0 0 0 / 0.05);
  --shadow-md: 0 4px 6px -1px rgba(0 0 0 / 0.1);
  --shadow-lg: 0 10px 15px -3px rgba(0 0 0 / 0.1);

  /* Transitions */
  --transition-fast: 150ms ease;
  --transition-base: 250ms ease;
  --transition-slow: 350ms ease;

  /* Z-index scale */
  --z-dropdown: 100;
  --z-sticky: 200;
  --z-overlay: 300;
  --z-modal: 400;
  --z-toast: 500;
}
```

## UI Patterns & Recipes

### Modal / Dialog
```html
<div role="dialog" aria-modal="true" aria-labelledby="modal-title">
  <div class="modal-backdrop" data-dismiss></div>
  <div class="modal-content">
    <header>
      <h2 id="modal-title">Modal Title</h2>
      <button aria-label="Close modal">&times;</button>
    </header>
    <main>Content here</main>
    <footer>
      <button class="btn btn-secondary">Cancel</button>
      <button class="btn btn-primary">Confirm</button>
    </footer>
  </div>
</div>
```
- Trap focus inside modal when open
- Close on Escape key and backdrop click
- Return focus to trigger element on close
- Prevent body scroll when open

### Dropdown / Select
```html
<div class="dropdown" data-dropdown>
  <button aria-expanded="false" aria-haspopup="listbox">
    Options <span aria-hidden="true">▾</span>
  </button>
  <ul role="listbox" hidden>
    <li role="option" aria-selected="true">Option 1</li>
    <li role="option">Option 2</li>
    <li role="option">Option 3</li>
  </ul>
</div>
```
- Open on click, close on outside click or Escape
- Keyboard navigation: Arrow keys, Enter, Escape
- Position: prefer below, flip to above if no space

### Tabs
```html
<div role="tablist">
  <button role="tab" aria-selected="true" aria-controls="panel-1" id="tab-1">Tab 1</button>
  <button role="tab" aria-selected="false" aria-controls="panel-2" id="tab-2">Tab 2</button>
  <button role="tab" aria-selected="false" aria-controls="panel-3" id="tab-3">Tab 3</button>
</div>
<div role="tabpanel" id="panel-1" aria-labelledby="tab-1">Content 1</div>
<div role="tabpanel" id="panel-2" aria-labelledby="tab-2" hidden>Content 2</div>
<div role="tabpanel" id="panel-3" aria-labelledby="tab-3" hidden>Content 3</div>
```
- Left/Right arrows navigate tabs
- Tab panel gets focus on tab activation (optional: manual activation)
- No tab should be disabled — use aria-selected instead

### Accordion
```html
<div class="accordion">
  <details>
    <summary>Section Title</summary>
    <div class="accordion-content">
      <p>Expandable content here</p>
    </div>
  </details>
</div>
```
- Use native `<details>` for simple cases
- For custom animations, use `grid-template-rows` trick:
```css
details[open] .accordion-content {
  display: grid;
  grid-template-rows: 1fr;
}
details .accordion-content {
  display: grid;
  grid-template-rows: 0fr;
  transition: grid-template-rows 0.3s ease;
}
```

### Breadcrumbs
```html
<nav aria-label="Breadcrumb">
  <ol class="breadcrumbs">
    <li><a href="/">Home</a></li>
    <li><a href="/section">Section</a></li>
    <li aria-current="page">Current Page</li>
  </ol>
</nav>
```
- Use ordered list for semantic order
- Separator via CSS `::before` pseudo-element
- Last item uses `aria-current="page"`

### Pagination
```html
<nav aria-label="Pagination">
  <ul class="pagination">
    <li><a href="?page=1" aria-label="Previous page">&laquo;</a></li>
    <li><a href="?page=1">1</a></li>
    <li><a href="?page=2" aria-current="page">2</a></li>
    <li><a href="?page=3">3</a></li>
    <li><span>...</span></li>
    <li><a href="?page=10">10</a></li>
    <li><a href="?page=3" aria-label="Next page">&raquo;</a></li>
  </ul>
</nav>
```
- Show current page with `aria-current`
- Truncate with ellipsis for many pages
- Always include prev/next with aria-labels

### Tooltip
```html
<button aria-describedby="tooltip-1">Hover me</button>
<div id="tooltip-1" role="tooltip" hidden>Helpful info</div>
```
- Show on hover AND focus
- Delay: 300ms show, 100ms hide
- Position dynamically based on viewport
- Never put interactive content in tooltips

### Toast / Notification
```html
<div role="status" aria-live="polite" class="toast">
  <span>Changes saved successfully</span>
  <button aria-label="Dismiss notification">&times;</button>
</div>
```
- Auto-dismiss after 4-6 seconds
- Use `role="alert"` for errors, `role="status"` for success/info
- Stack multiple toasts vertically
- Include undo action when appropriate

## Page Layout Patterns

### Dashboard Layout
```
┌─────────────────────────────────────┐
│              Header                 │
├──────────┬──────────────────────────┤
│          │  KPI Cards Row           │
│ Sidebar  ├──────────────────────────┤
│          │                          │
│ Nav      │  Main Content Area       │
│          │  (Charts, Tables)        │
│          │                          │
├──────────┴──────────────────────────┤
│              Footer                 │
└─────────────────────────────────────┘
```
- Sidebar: 240-280px fixed, collapsible on mobile
- KPI cards: 2-4 per row, responsive grid
- Content area: scrollable, sidebar fixed
- Use CSS Grid: `grid-template-columns: 260px 1fr`

### Landing Page
```
┌─────────────────────────────────────┐
│         Nav (transparent)           │
├─────────────────────────────────────┤
│                                     │
│         Hero Section                │
│         (full viewport height)      │
│                                     │
├─────────────────────────────────────┤
│         Features Grid               │
├─────────────────────────────────────┤
│         Social Proof / Logos        │
├─────────────────────────────────────┤
│         Pricing / CTA               │
├─────────────────────────────────────┤
│         FAQ / Accordion             │
├─────────────────────────────────────┤
│         Footer                      │
└─────────────────────────────────────┘
```
- Hero: strong headline, subtext, primary CTA, visual
- Features: 3-column grid on desktop, stacked on mobile
- Social proof: logo strip, testimonials, stats
- Alternating section backgrounds for visual separation

### Admin Panel
```
┌────────┬────────────────────────────┐
│ Logo   │ Search          User ▼     │
├────────┼────────────────────────────┤
│ Dashboard │  Page Title    [Action] │
│ Users     ├─────────────────────────┤
│ Products  │  Filters / Tabs         │
│ Orders    ├─────────────────────────┤
│ Settings  │  Data Table             │
│           │  [Pagination]           │
└──────────┴─────────────────────────┘
```
- Table: sortable columns, row actions, bulk select
- Filters above table, collapsible on mobile
- Breadcrumbs for deep navigation
- Quick actions accessible from header

### Blog / Article Layout
```
┌─────────────────────────────────────┐
│              Header                 │
├─────────────────────────────────────┤
│         Article Title               │
│         Meta (author, date, tags)   │
├────────┬────────────────────────────┤
│ TOC    │  Article Content           │
│ (sticky│  (max-width: 65ch)         │
│  left) │                            │
│        │  Related Posts             │
├────────┴────────────────────────────┤
│         Comments                    │
├─────────────────────────────────────┤
│              Footer                 │
└─────────────────────────────────────┘
```
- Content max-width: 65-75ch for readability
- Table of contents: sticky, highlights current section
- Generous whitespace between paragraphs
- Pull quotes, code blocks with syntax highlighting

### E-Commerce Product Grid
```
┌─────────────────────────────────────┐
│  Header: Logo  Search  Cart(3)      │
├─────────────────────────────────────┤
│ Filters │  Sort: [Relevance ▼]      │
│ (left)  ├───────────────────────────┤
│         │ ┌───┐ ┌───┐ ┌───┐ ┌───┐  │
│         │ │   │ │   │ │   │ │   │  │
│         │ └───┘ └───┘ └───┘ └───┘  │
│         │ ┌───┐ ┌───┐ ┌───┐ ┌───┐  │
│         │ │   │ │   │ │   │ │   │  │
│         │ └───┘ └───┘ └───┘ └───┘  │
└─────────┴───────────────────────────┘
```
- Product card: image, title, price, rating, quick add
- Filters: collapsible on mobile (drawer)
- Grid: 2 cols mobile, 3 tablet, 4 desktop
- Infinite scroll or pagination with "Load more"

## Dark Mode Implementation

### System Preference Detection
```css
@media (prefers-color-scheme: dark) {
  :root {
    --bg-primary: #0f0f0f;
    --bg-secondary: #1a1a1a;
    --text-primary: #e5e5e5;
    --text-secondary: #a3a3a3;
    --border-color: #2a2a2a;
  }
}
```

### Manual Toggle with CSS Variables
```css
:root {
  --bg-primary: #ffffff;
  --bg-secondary: #f5f5f5;
  --text-primary: #171717;
  --text-secondary: #525252;
  --border-color: #e5e5e5;
}

[data-theme="dark"] {
  --bg-primary: #0f0f0f;
  --bg-secondary: #1a1a1a;
  --text-primary: #e5e5e5;
  --text-secondary: #a3a3a3;
  --border-color: #2a2a2a;
}
```

```js
// Respect system preference, allow override
const stored = localStorage.getItem('theme');
const system = window.matchMedia('(prefers-color-scheme: dark)').matches;
document.documentElement.dataset.theme = stored || (system ? 'dark' : 'light');
```

### Color Conversion Strategy
- Don't simply invert colors — adjust each token
- Dark mode needs lower saturation for readability
- Use lighter grays instead of pure white text
- Elevate surfaces with lighter backgrounds, not shadows
- Test contrast ratios in both modes

### Common Dark Mode Mistakes
- Pure white (#fff) text on pure black (#000) — causes eye strain
- Same saturation as light mode — appears too vibrant
- Shadows for elevation — invisible on dark backgrounds
- Forgetting images — may need brightness adjustment
- Ignoring focus states — often designed for light only

### Smooth Theme Transition
```css
/* Apply transition to theme-aware properties only */
[data-theme] {
  transition: background-color 0.3s ease, color 0.3s ease, border-color 0.3s ease;
}

/* Exclude elements that shouldn't transition */
.no-theme-transition,
.no-theme-transition * {
  transition: none !important;
}
```

## Component Recipes

### Button System
```css
.btn {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  gap: var(--space-sm);
  padding: var(--space-sm) var(--space-lg);
  font-weight: 500;
  border-radius: var(--radius-md);
  border: 1px solid transparent;
  cursor: pointer;
  transition: all var(--transition-fast);
  min-height: 40px;
  min-width: 44px;
}

.btn:focus-visible {
  outline: 2px solid var(--color-primary);
  outline-offset: 2px;
}

.btn-primary {
  background: var(--color-primary);
  color: white;
}
.btn-primary:hover { background: var(--color-primary-dark); }

.btn-secondary {
  background: transparent;
  border-color: var(--border-color);
  color: var(--text-primary);
}
.btn-secondary:hover { background: var(--bg-secondary); }

.btn-ghost {
  background: transparent;
  color: var(--text-primary);
}
.btn-ghost:hover { background: var(--bg-secondary); }

.btn-danger {
  background: #dc2626;
  color: white;
}
.btn-danger:hover { background: #b91c1c; }

.btn[disabled] {
  opacity: 0.5;
  cursor: not-allowed;
  pointer-events: none;
}
```

### Card Component
```css
.card {
  background: var(--bg-primary);
  border: 1px solid var(--border-color);
  border-radius: var(--radius-lg);
  overflow: hidden;
  transition: box-shadow var(--transition-base), transform var(--transition-fast);
}

.card:hover {
  box-shadow: var(--shadow-lg);
  transform: translateY(-2px);
}

.card-image {
  aspect-ratio: 16 / 9;
  object-fit: cover;
  width: 100%;
}

.card-body {
  padding: var(--space-lg);
}

.card-title {
  font-size: var(--text-lg);
  font-weight: 600;
  margin-bottom: var(--space-sm);
}

.card-description {
  color: var(--text-secondary);
  line-height: 1.6;
}
```

### Input / Form Field
```css
.form-group {
  display: flex;
  flex-direction: column;
  gap: var(--space-xs);
}

.form-label {
  font-size: var(--text-sm);
  font-weight: 500;
  color: var(--text-primary);
}

.form-label .required {
  color: #dc2626;
  margin-left: 2px;
}

.form-input {
  padding: var(--space-sm) var(--space-md);
  border: 1px solid var(--border-color);
  border-radius: var(--radius-md);
  background: var(--bg-primary);
  color: var(--text-primary);
  font-size: var(--text-base);
  transition: border-color var(--transition-fast), box-shadow var(--transition-fast);
  min-height: 40px;
}

.form-input:focus {
  outline: none;
  border-color: var(--color-primary);
  box-shadow: 0 0 0 3px hsl(220 90% 56% / 0.2);
}

.form-input:invalid:not(:placeholder-shown) {
  border-color: #dc2626;
}

.form-error {
  font-size: var(--text-sm);
  color: #dc2626;
  display: flex;
  align-items: center;
  gap: var(--space-xs);
}

.form-hint {
  font-size: var(--text-sm);
  color: var(--text-secondary);
}
```

### Badge / Tag
```css
.badge {
  display: inline-flex;
  align-items: center;
  padding: 2px var(--space-sm);
  font-size: 0.75rem;
  font-weight: 500;
  border-radius: var(--radius-full);
  line-height: 1.4;
}

.badge-success { background: #dcfce7; color: #166534; }
.badge-warning { background: #fef3c7; color: #92400e; }
.badge-error   { background: #fee2e2; color: #991b1b; }
.badge-info    { background: #dbeafe; color: #1e40af; }
.badge-neutral { background: #f3f4f6; color: #374151; }
```

### Skeleton Loading
```css
.skeleton {
  background: linear-gradient(
    90deg,
    var(--bg-secondary) 25%,
    hsl(0 0% 85% / 0.3) 50%,
    var(--bg-secondary) 75%
  );
  background-size: 200% 100%;
  animation: shimmer 1.5s infinite;
  border-radius: var(--radius-md);
}

@keyframes shimmer {
  0% { background-position: 200% 0; }
  100% { background-position: -200% 0; }
}

.skeleton-text { height: 1em; margin-bottom: var(--space-sm); }
.skeleton-title { height: 1.5em; width: 60%; margin-bottom: var(--space-md); }
.skeleton-avatar { width: 48px; height: 48px; border-radius: 50%; }
.skeleton-image { aspect-ratio: 16 / 9; width: 100%; }
```

## Performance Optimization

### CSS Performance
- Use `content-visibility: auto` for off-screen sections
- Apply `contain: layout style paint` for isolated components
- Prefer `transform` and `opacity` for animations (GPU-accelerated)
- Avoid expensive properties in animations: `width`, `height`, `top`, `left`
- Use `will-change` sparingly and remove after animation

### Font Loading
```css
@font-face {
  font-family: 'Inter';
  src: url('/fonts/inter.woff2') format('woff2');
  font-display: swap;
  font-weight: 100 900;
}

/* Preconnect to font CDN */
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
```

### Image Optimization
- Use modern formats: WebP, AVIF with fallbacks
- Implement responsive images with `srcset` and `sizes`
- Lazy load below-fold images: `loading="lazy"`
- Use `decoding="async"` for non-critical images
- Define `width` and `height` to prevent CLS

```html
<picture>
  <source srcset="image.avif" type="image/avif">
  <source srcset="image.webp" type="image/webp">
  <img src="image.jpg" alt="Description" loading="lazy" decoding="async" width="800" height="600">
</picture>
```

### Critical CSS
- Inline above-the-fold CSS in `<style>` tag
- Defer non-critical CSS with `media="print" onload="this.media='all'"`
- Keep critical CSS under 14KB (single TCP packet)

### Render Performance
- Minimize DOM depth (avoid >32 levels)
- Keep total DOM nodes under 1500
- Use CSS `:has()` instead of JS parent queries
- Debounce scroll/resize handlers
- Use `IntersectionObserver` for lazy loading and scroll animations

### Measuring Performance
- Lighthouse for audits (target: 90+ Performance)
- Web Vitals: LCP < 2.5s, FID < 100ms, CLS < 0.1
- Use `performance.mark()` for custom timing
- Monitor with Real User Monitoring (RUM)

## UX Best Practices

### Forms
- Inline validation with clear error messages
- Show password visibility toggle
- Auto-focus first field
- Preserve form data on error
- Indicate required vs optional clearly
- Group related fields with fieldset/legend

### Navigation
- Limit primary nav items to 7±2
- Show current location clearly
- Provide breadcrumbs for deep hierarchies
- Include search for content-heavy sites
- Make back/forward navigation obvious

### Feedback & Communication
- Confirm destructive actions
- Show loading indicators for operations >200ms
- Use toast notifications for transient messages
- Provide progress indicators for long operations
- Celebrate success moments appropriately

### Content Strategy
- Use plain language, avoid jargon
- Front-load important information
- Write scannable content with headings and lists
- Provide helpful empty states
- Use progressive disclosure for complex information

## When to Use Me

Use this skill when:
- Building new UI components or pages
- Improving existing interface design
- Implementing design systems
- Enhancing accessibility
- Creating responsive layouts
- Adding animations and transitions
- Reviewing UI for design quality
- Establishing design tokens

## Quality Checklist

Before considering UI complete:
- [ ] Visual hierarchy is clear and intentional
- [ ] Color contrast meets WCAG AA
- [ ] Keyboard navigation works fully
- [ ] Responsive at all breakpoints
- [ ] Loading, error, and empty states handled
- [ ] Animations respect prefers-reduced-motion
- [ ] Touch targets are 44x44px minimum
- [ ] Focus indicators are visible
- [ ] Typography scale is consistent
- [ ] Spacing follows the design system
- [ ] No horizontal scroll on mobile
- [ ] Images optimized with proper alt text
