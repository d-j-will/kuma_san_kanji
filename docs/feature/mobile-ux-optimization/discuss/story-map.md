# Story Map: Mobile UX Optimization

## User: Yuki Tanaka (commuter learner, iPhone, one-handed use)

## Goal: Complete satisfying kanji study sessions on mobile during 25-minute commute

## Backbone

| Open App | Browse Dashboard | Select Group | Learn Kanji | Take Quiz | Review Results | Explore Kanji |
|----------|-----------------|--------------|-------------|-----------|---------------|---------------|
| App shell viewport | Mobile card layout | Touch-friendly grid | Mobile teach tabs | Touch-friendly input | Stacked action buttons | Accordion sections |
| Bottom tab nav | Touch-friendly stats | Kanji sizing (48px) | Swipe tab gestures | 16px+ input font | Full-width buttons | Progressive disclosure |
| Safe area insets | Single-column cards | Full-width CTA | Full-width nav buttons | Full-width submit | Scrollable results table | Touch accordion headers |
| Compact header | Readable text (16px+) | Learned indicators | Large kanji (72-128px) | Large kanji (72px+) | Mobile celebration | Swipe for next kanji |
| Dynamic viewport (dvh) | | Back navigation | Stroke order mobile | Keyboard avoidance | | |
| Performance CSS | | | Prev/next kanji touch | Feedback card mobile | | |
| Reduced motion | | | | | | |

---

### Walking Skeleton

The thinnest end-to-end mobile-optimized slice that touches every activity:

| Open App | Browse Dashboard | Select Group | Learn Kanji | Take Quiz | Review Results | Explore Kanji |
|----------|-----------------|--------------|-------------|-----------|---------------|---------------|
| App shell with `100dvh` + CSS Grid layout | Single-column group card stack | Kanji grid with 48px+ characters | Large kanji display (72-128px) | Input with 16px+ font (no iOS zoom) | Stacked full-width action buttons | Primary info always visible |
| Bottom tab bar (4 items) | Touch-friendly card targets (48px) | Touch-friendly grid cells (48px) | Touch-friendly tab indicators (48px) | Full-width submit button (48px height) | | Accordion headers for secondary info |
| Safe area inset padding | | Full-width Continue Learning button | Full-width Next/Back buttons | | | |

**Rationale**: This skeleton ensures every page in the app is usable on mobile with proper touch targets, readable text, and no layout-breaking issues. Without this slice, the app is fundamentally unusable on phones.

---

### Release 1: Core Mobile Shell (Outcome: mobile users can navigate and study without frustration)

**Tasks**:
- App shell: `100dvh` body with CSS Grid (`auto 1fr auto`)
- Bottom tab bar component with 4 items (Learn, Explore, Quiz, Profile)
- Active tab highlighting based on current route
- Safe area insets via `env(safe-area-inset-*)` + `viewport-fit=cover`
- Compact mobile header (reduced padding, smaller logo)
- Dynamic viewport units (`dvh`/`svh` instead of `vh`)
- Hide desktop footer on mobile (replaced by bottom nav)

**Outcome KPI**: Mobile users complete a full study session (dashboard -> teach -> quiz -> results) without layout issues

---

### Release 2: Touch-Optimized Content (Outcome: mobile users interact without mis-taps or readability issues)

**Tasks**:
- Learn dashboard: single-column card layout on mobile
- Group detail: kanji grid cells with 48px+ characters and 48px+ tap targets
- Teach page: large kanji display (72-128px), touch-friendly tab indicators
- Quiz: 16px+ input font, full-width buttons, keyboard avoidance
- Results: stacked action buttons, scrollable results table
- All buttons minimum 48px height on mobile
- Body text minimum 16px, line-height 1.5

**Outcome KPI**: Mobile users experience zero mis-taps and can read all content without zooming

---

### Release 3: Gesture & Progressive Disclosure (Outcome: mobile interaction feels native, content discovery is efficient)

**Tasks**:
- Teach page: swipe left/right gesture for tab navigation (LiveView JS hook)
- Explore page: accordion/collapsible sections for secondary content
- Explore page: primary info (kanji, grade, meanings) always visible
- Explore page: swipe for next kanji (optional)
- Quiz: keyboard dismiss and scroll-into-view for input

**Outcome KPI**: Mobile users navigate teach tabs via swipe more than tap, explore page bounce rate decreases

---

### Release 4: Performance & Polish (Outcome: mobile experience feels fast and accessible)

**Tasks**:
- `content-visibility: auto` for off-screen sections
- `overscroll-behavior: contain` on scrollable areas
- `prefers-reduced-motion` media query support
- Skeleton loading states for slow connections
- LiveView reconnection UX (banner during disconnect)
- Smooth CSS transitions (100-200ms for state changes)

**Outcome KPI**: Time to interactive under 3 seconds on 3G, zero jank during scroll
