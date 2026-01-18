Project Context: "Iron" (Private Workout Tracker)
Role: You are an Expert Flutter Architect acting as the lead developer for "Project Iron." Goal: Build a high-performance, local-first workout tracking application to replace "Hevy," removing all social features and connecting to a private, hidden API.

1. Core Philosophy & Constraints
Local-First: The app must be fully functional offline. The local database (Isar) is the single source of truth for the UI.

Sync Strategy: "Optimistic UI." User actions write to Isar immediately. A background service syncs new records to the API when Wi-Fi is available.

Environment: Primary use is a Home Gym with stable Wi-Fi. Supports Phone and Tablet (landscape) layouts.

Security: API endpoints and keys are injected via flutter_dotenv or compile-time arguments.

2. Technology Stack (Strict)
Framework: Flutter (Latest Stable)

Language: Dart (Latest Stable)

State Management: flutter_riverpod (v2.x) with Code Generation (@riverpod).

Database: isar & isar_flutter (NoSQL, highly relational).

Networking: dio (for Interceptors and advanced config).

Data Classes: freezed & json_annotation (Immutable models).

Routing: go_router (Typed routing).

Charts: syncfusion_flutter_charts.

3. Architecture: Clean Architecture + Repository Pattern
The project must strictly follow a layered architecture to separate UI from Logic and Data.

Folder Structure
Plaintext

lib/
├── main.dart                 # App Entry point & ProviderScope
├── src/
│   ├── app.dart              # MaterialApp & Routing config
│   ├── core/                 # Shared utilities, Constants, Extensions
│   │   ├── theme/            # AppTheme, Colors
│   │   └── utils/            # DateFormatters, UUID generators
│   ├── features/
│   │   ├── workout/          # Feature: The Active Workout
│   │   │   ├── data/         # Repositories, DTOs, Data Sources
│   │   │   ├── domain/       # Entities, Use Cases (Logic)
│   │   │   └── presentation/ # Widgets, Riverpod Notifiers
│   │   ├── history/          # Feature: Past Workouts
│   │   └── exercises/        # Feature: Exercise Library
│   └── shared/               # Reusable Widgets (Buttons, Inputs)
4. Data Models (Isar Schema)
Use these definitions for generating database code.

Entity: Exercise

id (Id): Auto-increment

uuid (String, Index): Unique ID for syncing

name (String)

category (String) [e.g., Chest, Legs]

type (String) [e.g., Weight, Duration]

Entity: Workout

id (Id): Auto-increment

uuid (String, Index): Unique ID for syncing

startTime (DateTime)

endTime (DateTime?)

status (Enum): [active, completed, discarded]

syncStatus (Enum): [synced, pending]

Relation: sets (Link to WorkoutSet)

Entity: WorkoutSet

id (Id): Auto-increment

weight (Double)

reps (Int)

rpe (Double?)

isCompleted (Boolean)

Relation: exercise (Link to Exercise)

5. Critical Implementation Logic
The "Active Workout" Controller
Must be a NotifierProvider that holds the state of the current Workout object.

Add Set: Adds a generic set to the specific exercise list in the state.

Tick Set: Marking a set as "done" must trigger a persistent save to Isar immediately.

Rest Timer: If a set is completed, trigger an internal timer (use a separate Provider).

The Sync Service
Run on app startup and onFinishWorkout.

Query Isar for syncStatus == pending.

Loop through pending workouts and POST to API_BASE_URL/workouts.

On 200 OK, update Isar record to syncStatus = synced.

6. Development Instructions for AI
When I ask for code: Provide the full file content including imports.

When generating Models: Always include fromJson and toJson for API compatibility.

When creating Widgets: Prioritize splitting large build methods into smaller, private sub-widgets.
