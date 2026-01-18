# Treoir - Workout Logging Extension

> Extending Treoir health dashboard with native workout logging

## 1. Project Context

### Vision
Extend Treoir from a read-only health dashboard (consuming Hevy/Withings APIs) into a full workout logging platform with owned data, reducing third-party API dependency.

### Target User
Solo garage gym athletes aged 30-55 who:
- Train alone at home
- Follow structured programming
- Want data-driven insights over social features
- Have outgrown spreadsheet-based tracking

### Core Value Proposition
"The thinking athlete's training log" — age-appropriate benchmarking, multi-modal tracking, and insights without the social noise.

---

## 2. Tech Stack

### Current (Inherited from Treoir)

| Layer | Technology | Version | Purpose |
|-------|------------|---------|---------|
| Frontend | Next.js | 15.5.9 | App Router, SSR, API routes |
| Frontend | React | 19.1.0 | UI components |
| Frontend | TypeScript | 5.x | Type safety |
| Frontend | Tailwind CSS | 4.x | Styling |
| Backend | Vercel | - | Hosting, serverless, edge |
| Auth | Supabase Auth | - | User authentication |
| Database | PostgreSQL | - | Primary data store (Supabase) |
| ORM | Drizzle | - | Type-safe queries, migrations |
| Caching | Upstash Redis | - | Rate limiting, session cache |

### New Dependencies (Phase 1)

| Technology | Purpose |
|------------|---------|
| Supabase Realtime | Live sync between phone and gym monitor |
| next-pwa | Progressive Web App capabilities |
| react-timer-hook | Rest timer functionality |

---

## 3. Architecture Decisions

### ADR-001: Extend Treoir vs New Flutter Project
**Decision:** Extend existing Treoir Next.js application  
**Rationale:**
- Supabase infrastructure already configured
- Drizzle ORM and migrations in place
- Single codebase reduces maintenance burden
- Faster path to MVP
- Claude Code team has existing context

**Trade-offs:**
- No native iOS app (PWA instead)
- Slightly less polished mobile UX than native Flutter
- Acceptable for solo garage gym use case

### ADR-001b: API-First Architecture
**Decision:** Design all API endpoints as standalone services, not web-app-coupled  
**Rationale:**
- Enables future Flutter/Swift native apps without API changes
- Web app becomes "just another client"
- Clean separation of concerns
- Supports potential third-party integrations

**Implementation:**
- All endpoints under `/api/v1/` prefix
- Bearer token auth (not cookie-only)
- JSON-only responses (no HTML redirects)
- Consistent error format
- OpenAPI spec for client generation

### ADR-002: PWA for Mobile Logging
**Decision:** Build responsive web app with PWA capabilities  
**Rationale:**
- Next.js 15 has strong PWA support via next-pwa
- Eliminates App Store deployment complexity
- Real-time sync via Supabase handles phone ↔ monitor use case
- Can add native wrapper (Capacitor) later if needed

### ADR-003: Own the Data
**Decision:** Store all workout data in Supabase, use Hevy only for historical import  
**Rationale:**
- API dependency risk (Hevy could change/revoke access)
- Enables features Hevy doesn't support (multi-modal, standards)
- Full control over data model
- Historical Hevy data imported once, then app is self-sufficient

### ADR-004: Supabase Realtime for Sync
**Decision:** Use Supabase Realtime subscriptions for live sync  
**Rationale:**
- Already part of Supabase stack (no new service)
- Sub-500ms latency on local network
- Handles conflict resolution via timestamps
- Phone creates/updates sets → monitor reflects instantly

---

## 4. System Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                         CLIENT LAYER                            │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌─────────────────┐              ┌─────────────────┐          │
│  │   iOS (PWA)     │◄────────────►│   Web (Browser) │          │
│  │   Workout Log   │   Realtime   │   Gym Monitor   │          │
│  └────────┬────────┘              └────────┬────────┘          │
│           │                                │                    │
│           └────────────┬───────────────────┘                    │
│                        │                                        │
└────────────────────────┼────────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────────┐
│                      NEXT.JS APP ROUTER                         │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  /app                                                           │
│  ├── (auth)/           → Login, signup (Supabase Auth)         │
│  ├── (dashboard)/      → Existing Treoir dashboard             │
│  ├── (workout)/        → NEW: Workout logging flows            │
│  │   ├── active/       → In-progress workout                   │
│  │   ├── history/      → Past workouts                         │
│  │   └── routines/     → Routine templates                     │
│  ├── (monitor)/        → NEW: Gym display mode                 │
│  └── api/                                                       │
│       ├── workouts/    → CRUD for workouts                     │
│       ├── exercises/   → Exercise library                      │
│       └── sync/        → Realtime coordination                 │
│                                                                 │
└─────────────────────────┬───────────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────────────┐
│                       DATA LAYER                                │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌─────────────────┐  ┌─────────────────┐  ┌────────────────┐  │
│  │    Supabase     │  │    Supabase     │  │    Upstash     │  │
│  │   PostgreSQL    │  │    Realtime     │  │     Redis      │  │
│  │                 │  │                 │  │                │  │
│  │  - users        │  │  - workout      │  │  - rate limit  │  │
│  │  - workouts     │  │    updates      │  │  - session     │  │
│  │  - sets         │  │  - set changes  │  │    cache       │  │
│  │  - exercises    │  │                 │  │                │  │
│  │  - routines     │  │                 │  │                │  │
│  │  - standards    │  │                 │  │                │  │
│  └─────────────────┘  └─────────────────┘  └────────────────┘  │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## 5. Key User Flows

### Flow 1: Start Workout from Routine
```
1. User opens app on phone (PWA)
2. Selects routine (e.g., "CLAUDE_LONGV Day 1")
3. App creates workout record in Supabase
4. First exercise displayed with previous performance
5. User logs sets, rest timer runs between
6. Gym monitor (web) shows live progress
7. User completes workout, summary displayed
8. Workout marked complete, stats calculated
```

### Flow 2: Gym Monitor Mode
```
1. User opens web app on gym monitor/TV
2. Selects "Monitor Mode" 
3. App subscribes to active workout via Realtime
4. Large display shows:
   - Current exercise + target sets/reps
   - Rest timer (synced with phone)
   - Next exercise preview
   - Session progress
5. Updates instantly as phone logs sets
```

### Flow 3: Quick Workout (No Routine)
```
1. User taps "Quick Workout"
2. Empty workout created
3. User searches/adds exercises ad-hoc
4. Logs sets for each
5. Save as new routine (optional)
```

---

## 6. File Structure (Proposed)

```
treoir/
├── app/
│   ├── (auth)/                    # Existing auth flows
│   ├── (dashboard)/               # Existing dashboard
│   ├── (workout)/                 # NEW
│   │   ├── layout.tsx
│   │   ├── page.tsx               # Workout home (history + start)
│   │   ├── active/
│   │   │   └── [id]/
│   │   │       └── page.tsx       # Active workout logging
│   │   ├── history/
│   │   │   └── [id]/
│   │   │       └── page.tsx       # Workout detail view
│   │   └── routines/
│   │       ├── page.tsx           # Routine list
│   │       └── [id]/
│   │           └── page.tsx       # Routine editor
│   ├── (monitor)/                 # NEW
│   │   └── page.tsx               # Gym display mode
│   └── api/
│       └── v1/                    # VERSIONED API (mobile-ready)
│           ├── workouts/
│           │   ├── route.ts       # GET (list), POST (create)
│           │   └── [id]/
│           │       ├── route.ts   # GET, PATCH, DELETE
│           │       └── exercises/
│           │           ├── route.ts
│           │           └── [exerciseId]/
│           │               └── sets/
│           │                   └── route.ts
│           ├── exercises/
│           │   └── route.ts       # GET (search), POST (custom)
│           ├── routines/
│           │   └── route.ts
│           └── openapi.json/
│               └── route.ts       # OpenAPI spec endpoint
├── components/
│   ├── workout/                   # NEW
│   │   ├── SetLogger.tsx
│   │   ├── RestTimer.tsx
│   │   ├── ExerciseCard.tsx
│   │   └── WorkoutSummary.tsx
│   └── monitor/                   # NEW
│       └── LiveDisplay.tsx
├── lib/
│   ├── api/                       # NEW: API utilities
│   │   ├── auth.ts                # Bearer token validation
│   │   ├── response.ts            # Standard response helpers
│   │   └── errors.ts              # Error codes and formatting
│   ├── db/
│   │   ├── schema/               # Drizzle schemas
│   │   │   ├── users.ts          # Existing
│   │   │   ├── workouts.ts       # NEW
│   │   │   ├── exercises.ts      # NEW
│   │   │   └── routines.ts       # NEW
│   │   └── migrations/
│   ├── supabase/
│   │   └── realtime.ts           # NEW: subscription helpers
│   └── standards/                # NEW: percentile data
│       └── strength-levels.json
└── docs/                         # This documentation
```

---

## 7. Security Model

### Row Level Security (RLS)
All workout tables will use Supabase RLS:
- Users can only read/write their own data
- No cross-user data access
- Service role key only in server-side API routes

### Auth Flow
- Supabase Auth (existing)
- Session tokens stored in HTTP-only cookies
- Middleware validates auth on protected routes

---

## 8. Performance Considerations

### Realtime Efficiency
- Subscribe only to active workout changes
- Unsubscribe when workout completes
- Debounce rapid set updates (300ms)

### Mobile Optimization
- Lazy load exercise library
- Prefetch next exercise data
- Cache routine data in localStorage
- Minimal JS bundle for workout logging pages

### Monitor Mode
- Long-polling fallback if WebSocket fails
- Auto-reconnect on connection drop
- Visual indicator for sync status

---

## 9. Future Considerations (Post-MVP)

### Mobile Native Apps (Separate Project)
The API is designed to support future Flutter or Swift apps as independent projects:
- **Flutter app** would consume `/api/v1/` endpoints
- **Swift app** would consume same endpoints
- Supabase SDKs handle auth and realtime on both platforms
- OpenAPI spec enables auto-generated API clients
- No changes required to Treoir web codebase

**Mobile development can proceed independently** once Phase 1A API is stable.

### Other Future Features
- **Apple Health integration** for Withings/cardio data
- **Offline support** with sync queue (mobile-first)
- **AI coaching** via Claude API
- **Program import** (5/3/1, GZCLP spreadsheets)
- **Standards integration** (StrengthLevel percentiles)

---

## 10. References

- [Supabase Realtime Docs](https://supabase.com/docs/guides/realtime)
- [Next.js PWA](https://github.com/shadowwalker/next-pwa)
- [Drizzle ORM](https://orm.drizzle.team/)
- Previous PRD conversation: Treoir workout extension research
