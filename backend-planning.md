# Stillpoint Backend Plan

**Created: July 15, 2026, 7:46 PM EDT**

## Context

Stillpoint is an iOS mindfulness app with gamification (XP, streaks, badges, character growth). The app currently has a full design system, static UI screens, and domain entities -- but zero persistence, zero networking, and zero backend. All repository implementations return hardcoded data.

The features require a server: auth with MFA/SMS, password reset via email, server-authoritative XP/streak calculation, cross-device data, and eventually watchOS support. The goal is to ship fast while building something robust and fully testable.

**Decision: Firebase as the backend, SwiftData for local drafts only.**

Firebase Auth, Cloud Firestore, and Cloud Functions cover all features without writing or deploying a custom server. Firestore's built-in offline cache replaces the need for a SwiftData sync layer. SwiftData is used only for local-only data (journal drafts, in-progress coloring state) that doesn't need cloud sync.

---

## Deployment Options (for reference)

| Option                                 | Pros                                                                                                                         | Cons                                                                                                                                   | Cost                                                                          |
| -------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------- |
| **Firebase (Recommended)**       | Zero server management; built-in auth/MFA/offline; push notifications included; watchOS SDK; generous free tier (Spark plan) | Vendor lock-in to Google; Firestore aggregation is limited (solved with pre-computed counters); Cloud Functions add cold-start latency | Free tier covers early usage; Blaze plan is pay-as-you-go (~$0.06/100K reads) |
| **Simple PaaS (Railway/Render)** | Full control over business logic; Postgres for powerful queries; no vendor lock-in                                           | You must write and maintain a server (Vapor/Node); deploy pipeline to manage; more code overall                                        | ~$10/month for server + managed Postgres                                      |
| **AWS/GCP**                      | Maximum control and scalability; every service available                                                                     | Significant setup overhead; IAM/networking complexity; overkill for a solo developer shipping v1                                       | Variable; easy to overspend without monitoring                                |

---

## Architecture

```
iOS App (SwiftUI)
  Features/ (Views + ViewModels)
      |
  Domain/ (Entities + Protocols)
      |
  Data/
    ├── Local/        -- SwiftData (journal drafts only)
    ├── Remote/        -- Firebase service wrappers
    └── Repositories/  -- Composite implementations
```

**Monorepo structure** (new items marked with `+`):

The repo root has two completely separate zones. Swift code lives under `stillpoint/`. Firebase backend code lives under `firebase/`. They share nothing -- different languages, different toolchains, different deploy targets.

```
stillPoint-app/                         (repo root)
│
├── stillpoint/                         ── iOS APP (Swift/SwiftUI) ──
│   ├── App/
│   │   ├── stillpointApp.swift              -- modified: FirebaseApp.configure(), inject Dependencies
│   │   ├── ContentView.swift
│   │ + └── Dependencies.swift               -- DI container
│   ├── Data/
│   │ + ├── Local/
│   │ + │   └── LocalJournalEntry.swift      -- SwiftData model for journal drafts
│   │ + ├── Remote/
│   │ + │   ├── AuthService.swift            -- wraps Firebase Auth SDK
│   │ + │   ├── FirestoreService.swift       -- wraps Firestore SDK reads/writes
│   │ + │   └── FunctionsService.swift       -- wraps Cloud Functions SDK calls
│   │   └── Repositories/
│   │       ├── ActivityRepositoryImpl.swift  -- rewritten to use Firestore
│   │       ├── MoodRepositoryImpl.swift      -- rewritten to use Firestore
│   │       ├── UserRepositoryImpl.swift      -- rewritten to use Firestore
│   │     + └── AuthRepositoryImpl.swift
│   ├── Domain/
│   │   ├── Entities/
│   │   │   ├── Activity.swift               -- existing
│   │   │   ├── Badge.swift                  -- existing
│   │   │   ├── Mood.swift                   -- existing
│   │   │   ├── Streak.swift                 -- existing
│   │   │   ├── UserProfile.swift            -- existing
│   │   │ + ├── ActivityCompletion.swift
│   │   │ + ├── ActivitySuggestion.swift
│   │   │ + ├── GamificationStatus.swift
│   │   │ + ├── Report.swift
│   │   │ + └── CharacterSelection.swift
│   │   └── Protocols/
│   │       ├── ActivityRepository.swift     -- modified: add throws + new methods
│   │       ├── MoodRepository.swift         -- modified: add throws + new methods
│   │       ├── UserRepository.swift         -- modified: add throws + new methods
│   │     + └── AuthRepository.swift
│   ├── Features/
│   │ + ├── Auth/
│   │ + │   ├── LoginView.swift
│   │ + │   ├── RegisterView.swift
│   │ + │   └── MFAView.swift
│   │   ├── Home/HomeView.swift
│   │   ├── Journey/JourneyView.swift
│   │   ├── Schedule/ScheduleView.swift
│   │   └── Profile/ProfileView.swift
│   ├── DesignSystem/                        -- unchanged
│   └── Resources/
│       └── GoogleService-Info.plist         -- Firebase config (gitignored)
│
├── firebase/                           ── BACKEND (TypeScript/Node.js) ──
│ + ├── functions/
│ + │   ├── src/
│ + │   │   ├── index.ts                     -- exports all functions
│ + │   │   ├── xp.ts                        -- XP calculation on activity completion
│ + │   │   ├── streaks.ts                   -- streak computation
│ + │   │   ├── badges.ts                    -- badge awarding logic
│ + │   │   ├── suggestions.ts              -- daily activity suggestion generation
│ + │   │   └── reports.ts                   -- pre-compute report aggregates
│ + │   ├── package.json
│ + │   └── tsconfig.json
│ + ├── firestore.rules                      -- security rules
│ + ├── firestore.indexes.json
│ + └── firebase.json                        -- Firebase project config + emulator settings
│
├── project.yml                              -- modified: add Firebase SPM dependencies
├── planning.md
├── frontend-planning.md
├── backend-planning.md
└── CLAUDE.md
```

**Separation boundaries:**

- `stillpoint/` is compiled by Xcode. It contains only Swift. XcodeGen (`project.yml`) points here for sources.
- `firebase/` is managed by the Firebase CLI. It contains only TypeScript/Node.js. Deployed via `firebase deploy`.
- They never import from each other. The only shared contract is the Firestore document schema (documented in this file).
- `GoogleService-Info.plist` goes in `stillpoint/Resources/` because it's an iOS build resource, but it's generated from the Firebase Console and gitignored.

---

## Firestore Data Model

```
users/{userId}
  ├── username: string
  ├── email: string
  ├── dateOfBirth: timestamp
  ├── characterType: string         -- "person" | "plant" | "bird" | "cat"
  ├── characterVariant: string      -- skin shade, gender, etc.
  ├── xp: number
  ├── growthStage: string           -- "newborn" | "sprouting" | "young" | "mature"
  ├── totalActivities: number
  ├── acceptedPolicy: boolean
  ├── acceptedDisclaimer: boolean
  ├── createdAt: timestamp
  └── updatedAt: timestamp

users/{userId}/streak (single doc)
  ├── currentDays: number
  ├── longestDays: number
  └── lastActivityDate: timestamp

users/{userId}/completions/{completionId}
  ├── activityType: string
  ├── completedAt: timestamp
  ├── durationSeconds: number
  └── xpAwarded: number

users/{userId}/moods/{moodId}
  ├── mood: string
  └── date: timestamp (start of day)

users/{userId}/badges/{badgeId}
  ├── name: string
  ├── description: string
  └── earnedAt: timestamp

users/{userId}/suggestions/{date}    -- e.g., "2026-07-15"
  ├── activities: array<{activityType, scheduledTime, status}>
  └── generatedAt: timestamp

users/{userId}/reports/{period}      -- e.g., "2026-W29", "2026-07", "2026"
  ├── activeDays: number
  ├── restDays: number
  ├── totalXP: number
  ├── bestStreak: number
  ├── activityBreakdown: map<string, number>
  └── computedAt: timestamp

```

**Activity catalog:** Hardcoded on the client (`Activity.samples` in `ActivityRepositoryImpl.swift`). May move to Firestore later if we need server-side updates without app releases.

**Why subcollections:** Completions and moods grow unbounded. Subcollections let Firestore paginate and query by date range without loading the entire user document.

---

## Cloud Functions (server-side business logic)

All XP, streak, badge, and report calculations happen in Cloud Functions -- the client never computes these, ensuring integrity.

| Function                     | Trigger                                       | Logic                                                                                                                    |
| ---------------------------- | --------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------ |
| `onActivityCompleted`      | Firestore`onCreate` on `completions/{id}` | Calculate XP (base + diversity bonus), update`users/{uid}.xp` and `growthStage`, update streak, check badge criteria |
| `onMoodLogged`             | Firestore`onCreate` on `moods/{id}`       | Award daily login XP (+5) if first mood today, update streak                                                             |
| `generateDailySuggestions` | Cloud Scheduler (daily at user's local 6 AM)  | Pick 3 diversified activities different from yesterday's, write to`suggestions/{date}`                                 |
| `computeWeeklyReport`      | Cloud Scheduler (every Monday)                | Aggregate last 7 days of completions/moods into`reports/{period}`                                                      |
| `computeMonthlyReport`     | Cloud Scheduler (1st of month)                | Aggregate last month                                                                                                     |

**XP calculation logic (in `xp.ts`):**

- Base XP from activity type (breathing: 20, journal: 25, coloring: 30, focus: 50)
- Diversity bonus: +25 if today's completed activity types differ from yesterday's
- Daily login (mood check-in): +5 (first mood entry per day only)
- Streak milestones: +75 one-time at 7, 14, 30, 60, 180, 365 days
- Growth stage thresholds: Newborn 0-200, Sprouting 201-1500, Young 1501-8000, Mature 8001-20000

---

## Auth Flow

Firebase Auth handles all of this natively:

1. **Register:** `Auth.auth().createUser(email, password)` + write user profile doc to Firestore
2. **Login:** `Auth.auth().signIn(email, password)`
3. **MFA setup:** `user.multiFactor.enroll()` with phone factor (Firebase supports phone-based MFA)
4. **MFA verify:** `resolver.resolveSignIn(with: phoneCredential)`
5. **Password reset:** `Auth.auth().sendPasswordReset(email)`
6. **Session:** Firebase Auth manages tokens automatically (access token refresh is handled by the SDK)

`AuthService.swift` wraps these calls and exposes them through `AuthRepository`.

---

## Protocol Changes

Add `throws` to all existing protocol methods (network/Firestore operations can fail):

```swift
// MoodRepository (updated)
protocol MoodRepository: Sendable {
    func logMood(_ mood: MoodType) async throws
    func getMoodHistory() async throws -> [MoodEntry]
    func getMoodHistory(from: Date, to: Date) async throws -> [MoodEntry]
}

// ActivityRepository (updated + new methods)
protocol ActivityRepository: Sendable {
    func getActivities() async throws -> [Activity]
    func getActivity(id: UUID) async throws -> Activity?
    func logCompletion(activityType: ActivityType, duration: Int) async throws
    func getCompletions(from: Date, to: Date) async throws -> [ActivityCompletion]
    func getTodaySuggestions() async throws -> [ActivitySuggestion]
    func respondToSuggestion(id: String, action: SuggestionAction) async throws
}

// UserRepository (updated + new methods)
protocol UserRepository: Sendable {
    func getProfile() async throws -> UserProfile
    func updateProfile(name: String) async throws
    func getStreak() async throws -> Streak
    func getBadges() async throws -> [Badge]
    func getGamificationStatus() async throws -> GamificationStatus
    func getReport(period: ReportPeriod) async throws -> Report
}

// New
protocol AuthRepository: Sendable {
    func register(username: String, email: String, password: String, dateOfBirth: Date) async throws
    func login(email: String, password: String) async throws -> AuthResult
    func verifyMFA(resolver: Any, code: String) async throws
    func setupMFA(phoneNumber: String) async throws
    func requestPasswordReset(email: String) async throws
    func logout() async throws
    var isAuthenticated: Bool { get }
    var currentUserId: String? { get }
}
```

---

## New Domain Entities

```swift
// ActivityCompletion
struct ActivityCompletion: Identifiable, Sendable {
    let id: String
    let activityType: ActivityType
    let completedAt: Date
    let durationSeconds: Int
    let xpAwarded: Int
}

// ActivitySuggestion
struct ActivitySuggestion: Identifiable, Sendable {
    let id: String
    let activityType: ActivityType
    let scheduledTime: Date?
    let status: SuggestionStatus  // pending, accepted, skipped, swapped
}

// GamificationStatus
struct GamificationStatus: Sendable {
    let xp: Int
    let growthStage: GrowthStage  // newborn, sprouting, young, mature
    let streakDays: Int
    let longestStreak: Int
}

// Report
struct Report: Sendable {
    let period: ReportPeriod
    let activeDays: Int
    let restDays: Int
    let totalXP: Int
    let bestStreak: Int
    let activityBreakdown: [ActivityType: Int]
}

// CharacterSelection
struct CharacterSelection: Sendable {
    let type: CharacterType  // person, plant, bird, cat
    let variant: String
}
```

---

## Dependency Injection

```swift
// App/Dependencies.swift
@MainActor
final class Dependencies: ObservableObject {
    let auth: AuthRepository
    let activities: ActivityRepository
    let moods: MoodRepository
    let user: UserRepository
}
```

Injected via `.environmentObject()` in `stillpointApp.swift`. ViewModels receive repositories through init parameters.

---

## Implementation Phases

### Phase 1: Local persistence + Firebase setup

- Add Firebase SDK via SPM (`FirebaseAuth`, `FirebaseFirestore`, `FirebaseFunctions`)
- Configure `GoogleService-Info.plist` and `FirebaseApp.configure()` in app entry point
- Create SwiftData model for journal drafts (`LocalJournalEntry`)
- Add `throws` to all repository protocols, fix all call sites
- Create new domain entities (`ActivityCompletion`, `GamificationStatus`, `Report`, etc.)
- **Verify:** Project compiles, all existing views still render with updated protocols

### Phase 2: Auth

- Implement `AuthService.swift` wrapping Firebase Auth
- Implement `AuthRepositoryImpl.swift`
- Build `LoginView`, `RegisterView`, `MFAView`
- Add auth state observation to gate app content
- **Verify:** Register a test account, log in, log out. Password reset sends email.

### Phase 3: Core data flow (Firestore)

- Implement `FirestoreService.swift` for reads/writes
- Rewrite `MoodRepositoryImpl` to read/write Firestore
- Rewrite `ActivityRepositoryImpl` to read catalog from Firestore + log completions
- Rewrite `UserRepositoryImpl` to read profile/streak/badges from Firestore
- Seed activity catalog in Firestore
- **Verify:** Log a mood in the app, check it appears in Firebase Console. Complete an activity, see the completion doc created.

### Phase 4: Server-side logic (Cloud Functions)

- Set up `firebase/functions/` with TypeScript
- Implement `onActivityCompleted`: XP calculation, growth stage, streak, badges
- Implement `onMoodLogged`: daily login XP
- Implement `generateDailySuggestions`: scheduled function
- Implement report pre-computation
- Write Firestore security rules (users can only read/write their own data; XP/streak fields are write-protected from client)
- **Verify:** Complete an activity in app, watch XP update in real-time via Firestore listener. Check streak increments after consecutive days.

### Phase 5: ViewModels + real data in UI

- Add `@Observable` ViewModels to each feature view
- HomeView: display real XP, streak, today's suggestions, character
- ProfileView: display real report data, badges
- ScheduleView: display real suggestions with accept/swap/skip
- JourneyView: display real mood history and activity log
- **Verify:** Full app walkthrough -- register, pick character, do mood check-in, complete an activity, see XP update, check profile report.

### Phase 6: MFA + polish

- Enable phone MFA in Firebase Console
- Implement MFA enrollment and verification flows
- Add push notifications for activity reminders (Firebase Cloud Messaging)
- **Verify:** Enable MFA on account, log out, log back in with SMS code.

---

## Testing Strategy

| Layer                             | What                                  | How                                                                                                                                         |
| --------------------------------- | ------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------- |
| **Cloud Functions**         | XP math, streak logic, badge rules    | Jest unit tests in`firebase/functions/`. Mock Firestore data, assert correct XP/stage/badge outputs                                       |
| **Firestore rules**         | Security rules                        | Firebase Emulator Suite +`@firebase/rules-unit-testing`. Test that users can't write to other users' data or modify their own XP directly |
| **Firebase services (iOS)** | `AuthService`, `FirestoreService` | Firebase Emulator Suite running locally. Real Firebase calls but against local emulator -- no production data touched                       |
| **Repositories (iOS)**      | `MoodRepositoryImpl`, etc.          | Protocol-based testing. Inject mock service conformances, verify correct Firestore calls are made                                           |
| **ViewModels (iOS)**        | Data flow, state transitions          | Inject stub repositories returning known data, assert ViewModel state matches expectations                                                  |
| **End-to-end**              | Full app flow                         | Firebase Emulator Suite + iOS Simulator. Register, log mood, complete activity, verify XP in Firestore, verify UI shows updated data        |

**Firebase Emulator Suite** is the key tool: it runs Auth, Firestore, and Functions locally so you can test the full stack without touching production. Configure it in `firebase.json`.

---

## Files to Modify (existing)

- `project.yml` -- add Firebase SPM dependencies
- `stillpoint/App/stillpointApp.swift` -- `FirebaseApp.configure()`, `ModelContainer`, inject `Dependencies`
- `stillpoint/Domain/Protocols/ActivityRepository.swift` -- add `throws`, new methods
- `stillpoint/Domain/Protocols/MoodRepository.swift` -- add `throws`, new methods
- `stillpoint/Domain/Protocols/UserRepository.swift` -- add `throws`, new methods
- `stillpoint/Data/Repositories/ActivityRepositoryImpl.swift` -- rewrite to use Firestore
- `stillpoint/Data/Repositories/MoodRepositoryImpl.swift` -- rewrite to use Firestore
- `stillpoint/Data/Repositories/UserRepositoryImpl.swift` -- rewrite to use Firestore
- `stillpoint/Features/Home/HomeView.swift` -- add ViewModel
- `stillpoint/Features/Profile/ProfileView.swift` -- add ViewModel
- `stillpoint/Features/Schedule/ScheduleView.swift` -- add ViewModel
- `stillpoint/Features/Journey/JourneyView.swift` -- add ViewModel

## TODO: Replace Gemini with Claude for Task Breakdown

The `analyzeTask` Cloud Function (`firebase/functions/src/taskBreakdown.ts`) uses Gemini 2.0 Flash as a temporary free alternative. Once Anthropic API credits are available, swap to Claude:

- **Model:** `claude-sonnet-5`
- **Secret:** Replace `GEMINI_API_KEY` with `ANTHROPIC_API_KEY` via `firebase functions:secrets:set`
- **API endpoint:** `https://api.anthropic.com/v1/messages`
- **Headers:** `x-api-key`, `anthropic-version: 2023-06-01`
- **Request body:** `{ model, max_tokens, messages: [{ role: "user", content }] }`
- **Response parsing:** `result.content[0].text` (strip markdown fences before JSON.parse)
