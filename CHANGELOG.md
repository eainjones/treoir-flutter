# Changelog

All notable changes to the Treoir Flutter app will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- CI/CD pipeline with GitHub Actions for automated testing
- QA test suite: 58 unit tests, 30 widget tests
- Shell script for API endpoint testing (`scripts/test-routines-api.sh`)
- Google OAuth authentication flow
- iOS deep link configuration for OAuth callbacks

### Changed
- Moved project from `~/Documents/GitHub/` to `~/Developer/` (iOS codesigning fix)

### Fixed
- iOS codesigning issues caused by iCloud extended attributes

---

## [1.0.0] - 2026-01-02

### Added
- **Workout Tracking**
  - Start workout from routine or blank
  - Log sets with weight, reps, RPE
  - Rest timer with customizable duration
  - Exercise notes

- **Routines**
  - Create, edit, delete routines
  - Add/remove exercises from routines
  - Reorder exercises via drag-and-drop
  - Duplicate routines

- **Exercise Library**
  - Exercise picker with search
  - Filter by muscle group
  - Exercise details and history

- **History**
  - View completed workouts
  - Workout detail with all exercises/sets
  - Duration and volume tracking

- **Authentication**
  - Email/password login
  - Supabase integration
  - Secure token storage (iOS Keychain)

### Technical
- Riverpod state management with code generation
- Isar local database for offline-first
- Freezed for immutable models
- Go Router for navigation
- Dio for HTTP client

---

## QA Notes

When reviewing PRs, check:
1. New features have corresponding tests
2. CHANGELOG.md is updated
3. Screenshots provided for UI changes
4. Manual testing on iOS simulator completed
