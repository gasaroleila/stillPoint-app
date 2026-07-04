# Stillpoint Design System Rules (Figma MCP Integration)

## 1. Token Definitions

### Colors

Defined in `stillpoint/DesignSystem/Tokens/Color+stillpoint.swift` as `Color` extensions with `sp` prefix.

| Token | Hex | Usage |
|---|---|---|
| `spPrimary` | `#FFD60A` | Primary accent (warm yellow) |
| `spPrimaryLight` | `#FFF8D6` | Light primary tint |
| `spBackground` | `#FAFAF8` | Main background (warm off-white) |
| `spBackgroundAlt` | `#F5F3EE` | Alternate/card background |
| `spTextPrimary` | `#0D0D0D` | Primary text (near-black) |
| `spTextSecondary` | `#7A7870` | Secondary/muted text |
| `spBorder` | `#E8E6E0` | Border/divider color |

**Figma variable mapping:** Create a `stillpoint/colors` collection with these exact names and hex values.

### Typography

Defined in `stillpoint/DesignSystem/Tokens/Font+stillpoint.swift`. Single font family: **Nunito**.

| Token | Weight | Size | Usage |
|---|---|---|---|
| `spLargeTitle` | Black (900) | 34pt | Screen titles |
| `spHeading` | Black (900) | 18pt | Section headings |
| `spCardTitle` | ExtraBold (800) | 16pt | Card titles |
| `spGreeting` | Bold (700) | 15pt | Greeting text |
| `spBody` | SemiBold (600) | 12.5pt | Body text |
| `spCaption` | Bold (700) | 11pt | Captions/labels |
| `spTabLabelActive` | ExtraBold (800) | 10.4pt | Active tab label |
| `spTabLabelInactive` | SemiBold (600) | 10.4pt | Inactive tab label |

**Font files available:** Nunito-Regular, Nunito-SemiBold, Nunito-Bold, Nunito-ExtraBold, Nunito-Black (+ Variable).

**Figma text styles:** Create text styles matching these tokens. Ensure Nunito font is loaded in Figma.

### Spacing & Layout Constants

Defined in `stillpoint/DesignSystem/Tokens/DesignConstants.swift` under `SP` enum namespace.

| Category | Token | Value |
|---|---|---|
| **Radius** | `SP.Radius.card` | 24pt |
| **Radius** | `SP.Radius.icon` | 16pt |
| **Radius** | `SP.Radius.pill` | 99pt (full pill) |
| **Padding** | `SP.Padding.card` | 17pt |
| **Padding** | `SP.Padding.screenHorizontal` | 20pt |
| **Spacing** | `SP.Spacing.section` | 12pt |
| **Shadow** | `SP.Shadow.cardOpacity` | 0.06 |

**Figma variables:** Create a `stillpoint/spacing` collection with these values.

## 2. Component Library

**Status: Early stage.** No reusable UI components exist yet. Feature views (Home, Journey, Schedule, Profile) are placeholder stubs with only title text.

**Architecture pattern:** SwiftUI `View` structs. Each feature view uses `NavigationStack` as root.

**No Storybook or component documentation exists.**

When designing in Figma, components should be created to match SwiftUI patterns:
- Cards with `SP.Radius.card` corner radius, `SP.Padding.card` internal padding
- Pill-shaped buttons with `SP.Radius.pill`
- Icon containers with `SP.Radius.icon`

## 3. Frameworks & Libraries

| Aspect | Value |
|---|---|
| **UI Framework** | SwiftUI (native Apple) |
| **Language** | Swift 6.1, strict concurrency |
| **Platform** | iOS 17.0+ |
| **Build System** | Xcode 26.4 / XcodeGen (`project.yml`) |
| **Architecture** | Clean Architecture (Domain/Data/Features layers) |
| **Dependencies** | None (no SPM packages) |

## 4. Asset Management

**Asset catalog:** `stillpoint/Resources/Assets.xcassets/`

Organized into subfolders (all currently empty, ready for assets):
- `AppIcon.appiconset/` - App icon
- `Badges/` - Achievement badge images
- `Colors/` - Named color sets (Xcode asset catalog colors)
- `Icons/` - Custom icons
- `Illustrations/` - Character illustrations, coloring pages
- `Moods/` - Mood emoji/illustrations

**Figma export convention:** Export assets as PDF (vector) or @2x/@3x PNG and place in the appropriate `Assets.xcassets` subfolder.

## 5. Icon System

**Primary:** SF Symbols (Apple's system icon library). Used via `systemImage:` parameter.

Current SF Symbol usage in tab bar:
- Home: `house.fill`
- Journey: `chart.bar.fill`
- Schedule: `calendar`
- Profile: `person.fill`

**Custom icons:** Will go in `Assets.xcassets/Icons/` (currently empty).

**Figma guideline:** Use SF Symbols where possible for consistency with iOS. For custom icons, export as PDF or SVG.

## 6. Styling Approach

**Pure SwiftUI modifiers.** No CSS, no third-party styling libraries.

Patterns:
```swift
// Color usage
.foregroundStyle(.spTextPrimary)
.background(.spBackground)

// Font usage
.font(.spHeading)

// Layout constants usage
.cornerRadius(SP.Radius.card)
.padding(SP.Padding.card)
.padding(.horizontal, SP.Padding.screenHorizontal)
```

**Responsive design:** SwiftUI's built-in layout system handles device adaptation. No explicit breakpoints.

**Dark mode:** Not yet implemented. Current palette is light-only. The warm yellow + off-white palette suggests a light-mode-first design.

## 7. Project Structure

```
stillpoint/
  App/
    stillpointApp.swift          # App entry point
    ContentView.swift            # Root TabView with 4 tabs
  DesignSystem/
    Tokens/
      Color+stillpoint.swift     # Color tokens
      Font+stillpoint.swift      # Typography tokens
      DesignConstants.swift      # Spacing/radius/shadow tokens
  Features/
    Home/HomeView.swift          # Home tab (placeholder)
    Journey/JourneyView.swift    # Journey/progress tab (placeholder)
    Schedule/ScheduleView.swift  # Schedule tab (placeholder)
    Profile/ProfileView.swift    # Profile tab (placeholder)
  Domain/
    Entities/
      Activity.swift             # Activity model (breathing, focus, coloring, journaling)
      Mood.swift                 # MoodType enum + MoodEntry
      UserProfile.swift          # User profile model
      Streak.swift               # Streak tracking
      Badge.swift                # Achievement badges
    Protocols/
      ActivityRepository.swift   # Activity data protocol
      MoodRepository.swift       # Mood data protocol
      UserRepository.swift       # User data protocol
  Data/
    Repositories/
      ActivityRepositoryImpl.swift
      MoodRepositoryImpl.swift
      UserRepositoryImpl.swift
  Resources/
    Assets.xcassets/             # Images, icons, colors
    Fonts/                       # Nunito font files (.ttf)
    Info.plist
```

**Pattern:** Feature-based organization. Each feature gets its own folder under `Features/`. Domain models are separate from UI. Clean Architecture with protocol-based repository pattern.

## 8. App Screens & Navigation

**Tab-based navigation** with 4 tabs:

| Tab | View | Purpose |
|---|---|---|
| Home | `HomeView` | Dashboard, daily activities, character display |
| Journey | `JourneyView` | XP progress, growth stages, streaks |
| Schedule | `ScheduleView` | Calendar integration, daily activity suggestions |
| Profile | `ProfileView` | User stats, reports, settings |

## 9. Domain Concepts (for Figma design context)

**Characters:** Person, Plant, Bird, Cat - each with growth stages (Newborn, Sprouting, Young, Mature).

**Activities:** Box Breathing (~2min), Deep Focus (20min+), Coloring (~5min), Journal (~10min).

**Moods:** Happy, Calm, Neutral, Sad, Stressed.

**Gamification:** XP system with daily 3-activity limit, streak milestones, diversity bonuses.

## 10. Figma-to-Code Mapping Rules

When translating Figma designs to SwiftUI:

1. **Always use design tokens** - never hardcode colors, fonts, or spacing values
2. **Token prefix:** All tokens use `sp` prefix for colors/fonts, `SP.` namespace for constants
3. **Corner radius:** Cards = 24, Icons = 16, Pills = 99
4. **Shadow:** Card shadow opacity = 0.06 (black)
5. **Screen padding:** 20pt horizontal
6. **Section spacing:** 12pt between sections
7. **Font family:** Nunito only, no system fonts except SF Symbols for icons
8. **Color palette:** Warm, natural tones - yellow primary, off-white backgrounds, near-black text
