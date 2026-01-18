# Treoir iOS App - Flutter Contractor Specification

> Native iOS workout logging app consuming Treoir REST API
> **Version:** 1.0 | **Last Updated:** January 2026

---

## 1. Project Overview

### What We're Building
A native iOS app for logging gym workouts. The backend API already exists (or is being built in parallel). Your job is the Flutter client only.

### Target User
Solo garage gym athlete, aged 30-55, who:
- Trains alone at home
- Wants to log workouts on their phone
- Optionally view progress on a gym monitor (web app - separate project)

### Core User Flow
```
Open App → Select Routine (or Quick Start) → Log Sets → Complete Workout → View History
```

---

## 2. Technical Stack

### Required
| Technology | Version | Purpose |
|------------|---------|---------|
| Flutter | 3.x (latest stable) | Cross-platform framework |
| Dart | 3.x | Language |
| Supabase Flutter SDK | latest | Auth + Realtime |
| Riverpod or Bloc | latest | State management (your choice) |

### Target Platform
- **iOS only** for v1 (iPad support nice-to-have)
- Minimum iOS version: 15.0
- Android can be added later (Flutter makes this easy)

### Backend
- REST API at `https://treoir.xyz/api/v1/`
- Supabase for auth and realtime
- You do NOT need to modify the backend

---

## 3. Authentication

### Supabase Auth
Use the Supabase Flutter SDK for all authentication.

**Supported Methods:**
- Email/Password (required)
- Magic Link (required)
- Apple Sign-In (required for App Store)
- Google Sign-In (nice-to-have)

### Auth Flow
```dart
// Initialize Supabase
await Supabase.initialize(
  url: 'https://[project].supabase.co',
  anonKey: '[anon-key]',
);

// Sign in
final response = await supabase.auth.signInWithPassword(
  email: email,
  password: password,
);

// Access token for API calls
final token = supabase.auth.currentSession?.accessToken;

// Use in API requests
final response = await http.get(
  Uri.parse('https://treoir.xyz/api/v1/workouts'),
  headers: {'Authorization': 'Bearer $token'},
);
```

### Token Refresh
Supabase SDK handles refresh automatically. Listen for auth state changes:
```dart
supabase.auth.onAuthStateChange.listen((data) {
  final event = data.event;
  if (event == AuthChangeEvent.tokenRefreshed) {
    // Token refreshed, update stored token
  }
  if (event == AuthChangeEvent.signedOut) {
    // Navigate to login
  }
});
```

### Secure Storage
Store tokens in iOS Keychain via `flutter_secure_storage`.

---

## 4. API Specification

### Base URL
```
Production: https://treoir.xyz/api/v1
```

### Authentication Header
```
Authorization: Bearer <supabase_access_token>
```

### Response Format
All responses follow this structure:

**Success:**
```json
{
  "success": true,
  "data": { ... },
  "meta": { "page": 1, "pageSize": 20, "total": 100, "hasMore": true }
}
```

**Error:**
```json
{
  "success": false,
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Human readable message",
    "details": [{ "field": "reps", "message": "Required" }]
  }
}
```

### HTTP Status Codes
| Code | Meaning |
|------|---------|
| 200 | Success |
| 201 | Created |
| 204 | Deleted (no content) |
| 400 | Validation error |
| 401 | Unauthorized (token invalid/expired) |
| 403 | Forbidden |
| 404 | Not found |
| 429 | Rate limited |

---

## 5. API Endpoints

### Workouts

#### List Workouts
```
GET /workouts?page=1&pageSize=20
```

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "id": "uuid",
      "name": "Push Day",
      "startedAt": "2026-01-15T09:30:00Z",
      "completedAt": "2026-01-15T10:45:00Z",
      "durationSeconds": 4500,
      "totalSets": 18,
      "totalReps": 156,
      "totalVolumeKg": 8450,
      "exerciseCount": 5
    }
  ],
  "meta": { "page": 1, "pageSize": 20, "total": 150, "hasMore": true }
}
```

#### Get Workout Detail
```
GET /workouts/:id
```

**Response:**
```json
{
  "success": true,
  "data": {
    "id": "uuid",
    "name": "Push Day",
    "notes": "Felt strong",
    "startedAt": "2026-01-15T09:30:00Z",
    "completedAt": "2026-01-15T10:45:00Z",
    "durationSeconds": 4500,
    "exercises": [
      {
        "id": "uuid",
        "orderIndex": 0,
        "notes": null,
        "exercise": {
          "id": "uuid",
          "name": "Barbell Bench Press",
          "primaryMuscle": "chest",
          "equipment": "barbell"
        },
        "sets": [
          {
            "id": "uuid",
            "orderIndex": 0,
            "reps": 8,
            "weightKg": 80.0,
            "rpe": 7,
            "setType": "working",
            "isCompleted": true,
            "completedAt": "2026-01-15T09:35:00Z"
          }
        ]
      }
    ]
  }
}
```

#### Create Workout
```
POST /workouts
Content-Type: application/json

{
  "name": "Push Day",           // optional
  "routineId": "uuid"           // optional - start from routine template
}
```

**Response:** `201 Created`
```json
{
  "success": true,
  "data": {
    "id": "uuid",
    "name": "Push Day",
    "startedAt": "2026-01-15T09:30:00Z",
    "completedAt": null,
    "exercises": []
  }
}
```

#### Complete Workout
```
PATCH /workouts/:id
Content-Type: application/json

{
  "completedAt": "2026-01-15T10:45:00Z",
  "notes": "Great session"
}
```

#### Delete Workout
```
DELETE /workouts/:id
```
**Response:** `204 No Content`

---

### Exercises (within a workout)

#### Add Exercise to Workout
```
POST /workouts/:workoutId/exercises
Content-Type: application/json

{
  "exerciseId": "uuid",
  "notes": "Focus on squeeze"    // optional
}
```

#### Remove Exercise
```
DELETE /workouts/:workoutId/exercises/:exerciseId
```

---

### Sets

#### Add Set
```
POST /workouts/:workoutId/exercises/:exerciseId/sets
Content-Type: application/json

{
  "reps": 8,
  "weightKg": 80.0,
  "rpe": 7,                      // optional, 1-10
  "setType": "working",          // "working" | "warmup" | "drop" | "failure" | "amrap"
  "isCompleted": true
}
```

#### Update Set
```
PATCH /workouts/:workoutId/exercises/:exerciseId/sets/:setId
Content-Type: application/json

{
  "reps": 10,
  "weightKg": 82.5
}
```

#### Delete Set
```
DELETE /workouts/:workoutId/exercises/:exerciseId/sets/:setId
```

---

### Exercise Library

#### Search Exercises
```
GET /exercises?q=bench&muscle=chest&equipment=barbell&page=1&pageSize=50
```

All query params optional.

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "id": "uuid",
      "name": "Barbell Bench Press",
      "category": "strength",
      "primaryMuscle": "chest",
      "secondaryMuscles": ["triceps", "shoulders"],
      "equipment": "barbell",
      "isCustom": false
    }
  ]
}
```

#### Create Custom Exercise
```
POST /exercises
Content-Type: application/json

{
  "name": "My Custom Exercise",
  "category": "strength",
  "primaryMuscle": "chest",
  "secondaryMuscles": ["triceps"],
  "equipment": "dumbbell"
}
```

---

### Routines (Templates)

#### List Routines
```
GET /routines
```

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "id": "uuid",
      "name": "CLAUDE_LONGV Day 1 - Lower Power",
      "exerciseCount": 6,
      "estimatedDuration": 60
    }
  ]
}
```

#### Get Routine Detail
```
GET /routines/:id
```

#### Start Workout from Routine
```
POST /routines/:id/start
```

Returns a new workout pre-populated with routine exercises.

---

## 6. Data Models (Dart)

```dart
// lib/models/workout.dart

class Workout {
  final String id;
  final String? name;
  final String? notes;
  final DateTime startedAt;
  final DateTime? completedAt;
  final int? durationSeconds;
  final int totalSets;
  final int totalReps;
  final double totalVolumeKg;
  final int exerciseCount;
  final List<WorkoutExercise>? exercises;

  Workout({
    required this.id,
    this.name,
    this.notes,
    required this.startedAt,
    this.completedAt,
    this.durationSeconds,
    this.totalSets = 0,
    this.totalReps = 0,
    this.totalVolumeKg = 0,
    this.exerciseCount = 0,
    this.exercises,
  });

  factory Workout.fromJson(Map<String, dynamic> json) => Workout(
    id: json['id'],
    name: json['name'],
    notes: json['notes'],
    startedAt: DateTime.parse(json['startedAt']),
    completedAt: json['completedAt'] != null 
      ? DateTime.parse(json['completedAt']) 
      : null,
    durationSeconds: json['durationSeconds'],
    totalSets: json['totalSets'] ?? 0,
    totalReps: json['totalReps'] ?? 0,
    totalVolumeKg: (json['totalVolumeKg'] ?? 0).toDouble(),
    exerciseCount: json['exerciseCount'] ?? 0,
    exercises: json['exercises'] != null
      ? (json['exercises'] as List).map((e) => WorkoutExercise.fromJson(e)).toList()
      : null,
  );

  bool get isActive => completedAt == null;
}

class WorkoutExercise {
  final String id;
  final int orderIndex;
  final String? notes;
  final Exercise exercise;
  final List<ExerciseSet> sets;

  WorkoutExercise({
    required this.id,
    required this.orderIndex,
    this.notes,
    required this.exercise,
    required this.sets,
  });

  factory WorkoutExercise.fromJson(Map<String, dynamic> json) => WorkoutExercise(
    id: json['id'],
    orderIndex: json['orderIndex'],
    notes: json['notes'],
    exercise: Exercise.fromJson(json['exercise']),
    sets: (json['sets'] as List).map((s) => ExerciseSet.fromJson(s)).toList(),
  );
}

class Exercise {
  final String id;
  final String name;
  final String category;
  final String primaryMuscle;
  final List<String>? secondaryMuscles;
  final String equipment;
  final bool isCustom;

  Exercise({
    required this.id,
    required this.name,
    required this.category,
    required this.primaryMuscle,
    this.secondaryMuscles,
    required this.equipment,
    this.isCustom = false,
  });

  factory Exercise.fromJson(Map<String, dynamic> json) => Exercise(
    id: json['id'],
    name: json['name'],
    category: json['category'],
    primaryMuscle: json['primaryMuscle'],
    secondaryMuscles: json['secondaryMuscles'] != null
      ? List<String>.from(json['secondaryMuscles'])
      : null,
    equipment: json['equipment'],
    isCustom: json['isCustom'] ?? false,
  );
}

class ExerciseSet {
  final String id;
  final int orderIndex;
  final int? reps;
  final double? weightKg;
  final int? rpe;
  final String setType;
  final bool isCompleted;
  final DateTime? completedAt;

  ExerciseSet({
    required this.id,
    required this.orderIndex,
    this.reps,
    this.weightKg,
    this.rpe,
    this.setType = 'working',
    this.isCompleted = false,
    this.completedAt,
  });

  factory ExerciseSet.fromJson(Map<String, dynamic> json) => ExerciseSet(
    id: json['id'],
    orderIndex: json['orderIndex'],
    reps: json['reps'],
    weightKg: json['weightKg']?.toDouble(),
    rpe: json['rpe'],
    setType: json['setType'] ?? 'working',
    isCompleted: json['isCompleted'] ?? false,
    completedAt: json['completedAt'] != null
      ? DateTime.parse(json['completedAt'])
      : null,
  );

  // Display weight in user's preferred unit
  String displayWeight(bool useImperial) {
    if (weightKg == null) return '-';
    if (useImperial) {
      return '${(weightKg! * 2.20462).toStringAsFixed(1)} lbs';
    }
    return '${weightKg!.toStringAsFixed(1)} kg';
  }
}

class Routine {
  final String id;
  final String name;
  final int exerciseCount;
  final int? estimatedDuration;
  final List<RoutineExercise>? exercises;

  Routine({
    required this.id,
    required this.name,
    required this.exerciseCount,
    this.estimatedDuration,
    this.exercises,
  });

  factory Routine.fromJson(Map<String, dynamic> json) => Routine(
    id: json['id'],
    name: json['name'],
    exerciseCount: json['exerciseCount'],
    estimatedDuration: json['estimatedDuration'],
    exercises: json['exercises'] != null
      ? (json['exercises'] as List).map((e) => RoutineExercise.fromJson(e)).toList()
      : null,
  );
}
```

---

## 7. Real-Time Sync (Optional for v1)

### Use Case
User logs workout on phone. Gym monitor (web app) shows live progress.

### Implementation
Use Supabase Realtime to subscribe to workout changes:

```dart
final channel = supabase.channel('workout:$workoutId')
  .onPostgresChanges(
    event: PostgresChangeEvent.all,
    schema: 'public',
    table: 'sets',
    callback: (payload) {
      // Update local state with new/updated set
      print('Set changed: ${payload.newRecord}');
    },
  )
  .subscribe();

// Cleanup when leaving workout screen
await channel.unsubscribe();
```

**Note:** This is nice-to-have for v1. Focus on core logging first.

---

## 8. Screens & User Flows

### Screen List

| Screen | Priority | Description |
|--------|----------|-------------|
| Login/Signup | P0 | Auth screens |
| Workout Home | P0 | Start workout, recent history |
| Active Workout | P0 | Log sets, rest timer |
| Exercise Picker | P0 | Search/select exercise |
| Workout History | P0 | List of past workouts |
| Workout Detail | P0 | View completed workout |
| Routine List | P1 | Select routine to start |
| Settings | P1 | Units (kg/lbs), account |
| Exercise Detail | P2 | View exercise info |
| Create Exercise | P2 | Add custom exercise |

### Core Flow: Log a Workout

```
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│   Workout   │────▶│   Select    │────▶│   Active    │
│    Home     │     │   Routine   │     │   Workout   │
└─────────────┘     │  (optional) │     └──────┬──────┘
                    └─────────────┘            │
                                               ▼
                                        ┌─────────────┐
                                        │    Add      │
                                        │  Exercise   │◀─┐
                                        └──────┬──────┘  │
                                               │         │
                                               ▼         │
                                        ┌─────────────┐  │
                                        │   Log Set   │──┘
                                        │  (repeat)   │
                                        └──────┬──────┘
                                               │
                                               ▼
                                        ┌─────────────┐
                                        │   Finish    │
                                        │   Workout   │
                                        └──────┬──────┘
                                               │
                                               ▼
                                        ┌─────────────┐
                                        │   Summary   │
                                        └─────────────┘
```

### Active Workout Screen (Key Screen)

```
┌────────────────────────────────────┐
│  ← Back              00:45:32  ⏱️  │  ← Elapsed time
├────────────────────────────────────┤
│                                    │
│  Barbell Bench Press               │  ← Current exercise
│  Previous: 80kg × 8, 8, 7          │  ← Last performance
│                                    │
│  ┌──────┬──────┬──────┬─────────┐  │
│  │ Set  │  kg  │ Reps │   RPE   │  │
│  ├──────┼──────┼──────┼─────────┤  │
│  │  1   │  80  │  8   │    7    │  │  ← Completed (dimmed)
│  ├──────┼──────┼──────┼─────────┤  │
│  │  2   │  80  │  8   │    8    │  │  ← Completed
│  ├──────┼──────┼──────┼─────────┤  │
│  │  3   │ [80] │ [ ]  │   [ ]   │  │  ← Active set (inputs)
│  └──────┴──────┴──────┴─────────┘  │
│                                    │
│  [  + Add Set  ]                   │
│                                    │
│  ┌──────────────────────────────┐  │
│  │     REST: 1:30 remaining     │  │  ← Rest timer
│  │          [ Skip ]            │  │
│  └──────────────────────────────┘  │
│                                    │
├────────────────────────────────────┤
│  Next: Incline Dumbbell Press      │
├────────────────────────────────────┤
│                                    │
│  [  + Add Exercise  ]              │
│                                    │
│  [    Finish Workout    ]          │
│                                    │
└────────────────────────────────────┘
```

### Key UX Requirements

1. **Large touch targets** - Minimum 44pt for all interactive elements
2. **Number inputs** - Show numeric keyboard, support decimals (0.5kg)
3. **Rest timer** - Auto-start after completing set, audio/haptic alert
4. **Previous performance** - Show last time user did this exercise
5. **Swipe to delete** - Sets and exercises
6. **Quick weight adjustment** - +2.5 / -2.5 kg buttons

---

## 9. Offline Handling

### v1 Approach (Simple)
- Require internet connection
- Show clear error when offline
- Cache exercise library locally

### Future (v2)
- Queue operations when offline
- Sync when connection restored
- Full offline workout logging

---

## 10. Settings & Preferences

### User Preferences
| Setting | Options | Default | Storage |
|---------|---------|---------|---------|
| Weight Unit | kg / lbs | kg | Local |
| Default Rest Timer | 60/90/120/180s | 90s | Local |
| Timer Sound | On/Off | On | Local |
| Timer Vibration | On/Off | On | Local |

### Account
- View email
- Sign out
- Delete account (links to web)

---

## 11. Deliverables

### Phase 1 (MVP) - 4 weeks
- [ ] Auth (email, magic link, Apple)
- [ ] Workout home screen
- [ ] Start empty workout
- [ ] Add exercises from library
- [ ] Log sets (reps, weight, RPE)
- [ ] Rest timer
- [ ] Complete workout
- [ ] Workout history list
- [ ] Workout detail view
- [ ] Settings (units)

### Phase 2 - 2 weeks
- [ ] Routines list
- [ ] Start workout from routine
- [ ] Previous performance display
- [ ] Create custom exercise

### Phase 3 (Optional) - 2 weeks
- [ ] Real-time sync with web monitor
- [ ] Workout notes
- [ ] Exercise reordering

---

## 12. Technical Requirements

### Code Quality
- Clean architecture (presentation / domain / data layers)
- Unit tests for business logic
- Widget tests for key screens
- No hardcoded strings (use l10n ready structure)

### Performance
- App launch < 2 seconds
- Screen transitions < 300ms
- Smooth 60fps scrolling

### Error Handling
- Graceful API error handling
- Retry logic for network failures
- User-friendly error messages

---

## 13. Assets & Branding

### Provided
- App icon (will be provided)
- Color palette (will be provided)
- Logo (will be provided)

### Design Direction
- Clean, minimal UI
- Dark mode support (iOS system)
- No heavy graphics or animations
- Focus on usability over aesthetics

---

## 14. Communication & Handoff

### What You'll Receive
1. This spec document
2. Supabase project credentials (dev environment)
3. API base URL
4. Figma designs (if available) or approval to propose UI

### What You'll Deliver
1. Flutter source code (GitHub repo)
2. TestFlight build for review
3. Documentation for any deviations from spec

### Check-ins
- Weekly progress update
- Screen recordings of completed features
- Questions via [Slack/Discord/Email - TBD]

---

## 15. Open Questions

> These will be answered before contract starts:

1. **Figma designs** - Will designs be provided, or should contractor propose UI?
2. **App Store account** - Will client provide, or contractor submit?
3. **Analytics** - Any tracking requirements? (Mixpanel, Firebase, etc.)
4. **Crash reporting** - Sentry, Crashlytics, or none?
5. **CI/CD** - Codemagic, GitHub Actions, or manual builds?

---

## Appendix A: Supabase Credentials

> Will be provided separately via secure channel

```
SUPABASE_URL=https://[project].supabase.co
SUPABASE_ANON_KEY=[anon-key]
```

---

## Appendix B: API Endpoint Summary

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | /workouts | List workouts |
| POST | /workouts | Create workout |
| GET | /workouts/:id | Get workout detail |
| PATCH | /workouts/:id | Update/complete workout |
| DELETE | /workouts/:id | Delete workout |
| POST | /workouts/:id/exercises | Add exercise |
| DELETE | /workouts/:id/exercises/:id | Remove exercise |
| POST | /workouts/:id/exercises/:id/sets | Add set |
| PATCH | /workouts/:id/exercises/:id/sets/:id | Update set |
| DELETE | /workouts/:id/exercises/:id/sets/:id | Delete set |
| GET | /exercises | Search exercises |
| POST | /exercises | Create custom exercise |
| GET | /routines | List routines |
| GET | /routines/:id | Get routine detail |
| POST | /routines/:id/start | Start workout from routine |
