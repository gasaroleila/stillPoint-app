# Stillpoint

A mindfulness and mental wellness iOS app that helps users build consistent self-care habits through guided activities, smart scheduling, and gentle gamification.

## Features

- **Guided Activities** — Box Breathing, Deep Focus, Journaling, and Coloring exercises
- **Smart Scheduling** — Reads your calendar to find free slots and suggests activities that fit
- **Gamification** — XP system, growth stages, streak tracking, and celebration animations
- **Journey Tracking** — Weekly reports with mood summaries stored in Firestore
- **Character System** — Choose and grow a companion character that evolves with your progress

## Tech Stack

- **Platform:** iOS 17+, SwiftUI
- **Language:** Swift 6.1
- **Backend:** Firebase (Auth, Firestore, Cloud Functions)
- **Build:** XcodeGen (`project.yml`)
- **Dependencies:** None (pure Apple frameworks)

## Architecture

Clean Architecture with three layers:

```
stillpoint/
├── App/              # Entry point, root navigation
├── Domain/
│   ├── Entities/     # Activity, Mood, UserProfile, Streak, Badge
│   └── Protocols/    # Repository interfaces
├── Data/
│   ├── Repositories/ # Firestore-backed implementations
│   └── Local/        # CalendarService, SwiftData models
├── Features/         # Auth, Home, Journey, Schedule, Profile, Onboarding
├── DesignSystem/     # Tokens (colors, typography, spacing), reusable components
└── Resources/        # Assets, fonts (Nunito family), Info.plist
```

## Getting Started

1. Clone the repo
2. Run `xcodegen generate` to create the Xcode project
3. Open `stillpoint.xcodeproj`
4. Add your `GoogleService-Info.plist` for Firebase
5. Build and run on a simulator or device (iOS 17+)
