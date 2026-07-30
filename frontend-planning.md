# Frontend Planning

*Created: 2026-07-04*

Figma source: [stillPoint-app-design](https://www.figma.com/design/TkZMsb9bsyowJNzXRuOmrR/stillPoint-app-design?node-id=0-1&t=mkgYQUQbCbBqWEnL-1)

## Navigation Architecture

Tab-based root navigation (`TabView`) with 4 tabs. Activity screens are presented as full-screen modals (`.fullScreenCover`) from the Home tab.

```
TabView
  ├── Home (house.fill)
  ├── Journey (chart.bar.fill) — internal Week/Month/Year segmented control
  ├── Schedule (calendar)
  └── Profile (person.fill)

Home → Activity Modal (fullScreenCover)
  ├── Breathing Exercise (single screen, animated)
  ├── Deep Focus (4-step flow: Goal Input → Confirm → Timer → Complete)
  ├── Coloring (single screen, canvas + palette)
  └── Journal (single screen, prompt + text editor)
```

**Tab bar behavior:** Active tab shows a 48pt yellow circle behind its icon, label uses `spTabLabelActive`. Inactive tabs use `spTabLabelInactive` with `spTextSecondary` color. Border-top: 0.77pt `spBorder`.

---

## Design System

Find FIGMA_DESIGN_SYSTEM.md file (at the root) for base design rules used in this project.

### Additional Colors Needed

| Proposed Token          | Hex                       | Usage                                        |
| ----------------------- | ------------------------- | -------------------------------------------- |
| `spChartMedium`       | `#FFE57A`               | Chart bars (partial day)                     |
| `spChartLight`        | `#FFF3B0`               | Chart bars (low activity)                    |
| `spChartEmpty`        | `#EDE9DF`               | Chart bars (rest day)                        |
| `spActivityJournal`   | `#FFF3E0`<br /> <br /> | Journal breakdown bg (warm orange)           |
| `spActivityBreathing` | `#EAF7FD`               | Breathing breakdown bg (light blue)          |
| `spActivityFocus`     | `#F3EEFF`               | Focus breakdown bg (light purple)            |
| `spActivityColoring`  | `#FFF0F5`               | Coloring breakdown bg (light pink)           |
| `spOverlay`           | `rgba(0,0,0,0.12)`      | Dark overlay on yellow (profile level badge) |
| `spLockedBadgeBg`     | `#F2F0EB`               | Locked/unearned badge bg                     |
| `spStatusText`        | `#E6A800`               | Status indicator text ("On track")           |
| `spMoodLabelInactive` | `rgba(255,255,255,0.5)` | Unselected mood label on yellow bg           |

### Additional Typography Needed

| Proposed Token      | Font             | Size   | Line Height | Usage                                                      |
| ------------------- | ---------------- | ------ | ----------- | ---------------------------------------------------------- |
| `spPageTitle`     | Nunito-Black     | 24pt   | 28.8pt      | Journey/Profile/Schedule page titles                       |
| `spSubtitle`      | Nunito-Regular   | 12.8pt | 19.2pt      | Page subtitles                                             |
| `spSectionTitle`  | Nunito-ExtraBold | 13.6pt | 20.4pt      | Card section headers ("Activity Breakdown")                |
| `spSmallLabel`    | Nunito-SemiBold  | 9.9pt  | 14.88pt     | Stat labels, badge captions                                |
| `spStatLabel`     | Nunito-SemiBold  | 9.6pt  | 14.4pt      | "AVG", "BEST STREAK" (tracking 0.384pt, uppercase)         |
| `spChartLabel`    | Nunito-Bold      | 9.3pt  | 9.28pt      | Chart day labels (M, T, W...)                              |
| `spSegment`       | Nunito-ExtraBold | 12.8pt | 19.2pt      | Segmented control (tracking 0.256pt, capitalize)           |
| `spTimerDisplay`  | Nunito-Black     | ~48pt  | —          | Deep Focus timer "19:58"                                   |
| `spActivityLabel` | Nunito-ExtraBold | 10.4pt | 15.6pt      | Category labels ("DEEP FOCUS"), uppercase tracking 0.832pt |

### Additional Spacing Needed

| Proposed Token                | Value | Usage                          |
| ----------------------------- | ----- | ------------------------------ |
| `SP.Spacing.cardGap`        | 16pt  | Gap between items inside cards |
| `SP.Spacing.statsGap`       | 12pt  | Gap between stats items        |
| `SP.Spacing.chartBarGap`    | 4pt   | Gap between chart bars         |
| `SP.Shadow.profileCardBlur` | 16pt  | Profile card shadow blur       |
| `SP.Size.tabIcon`           | 24pt  | Tab bar icon size              |
| `SP.Size.tabActiveCircle`   | 48pt  | Active tab background circle   |
| `SP.Size.moodAvatar`        | 64pt  | Mood emoji container           |
| `SP.Size.activityIcon`      | 56pt  | Activity card icon container   |
| `SP.Size.badgeIcon`         | 56pt  | Badge container                |
| `SP.Size.playButton`        | 32pt  | Activity card play button      |

---

## Shared Components

### TabBarView

- 4 equal-width tabs, white bg, `spBorder` top border (0.77pt)
- Active: 48pt yellow circle behind 24pt icon, `spTabLabelActive` in `spPrimary`
- Inactive: 24pt icon, `spTabLabelInactive` in `spTextSecondary`
- Bottom padding 20pt (safe area)

### ActivityCard

- White bg, `SP.Radius.card`, `SP.Shadow.cardOpacity`, padding 17pt
- HStack: 56pt icon container (`spBackground` bg, 16pt radius) | VStack(title `spCardTitle`, description `spBody` in `spTextSecondary`, HStack of pills) | 32pt play button (`spPrimary` bg, 16pt radius, chevron.right)
- Duration pill: `spBackgroundAlt` bg, `SP.Radius.pill`, `spCaption` in `spTextSecondary`
- XP pill: `spPrimaryLight` bg, `SP.Radius.pill`, `spCaption` in `spTextPrimary`

### SectionCard

- White bg, `SP.Radius.card`, drop shadow (0px 2px 8px @ 0.06), padding 20pt
- Optional title (`spSectionTitle`) at top

### StatsRow

- HStack of 3 equal-width items, 12pt gap
- Each: `spPrimaryLight` bg, 16pt radius, VStack(HStack(icon 14pt + value `spGreeting`) + label `spStatLabel` uppercase)

### SegmentedControl

- `spBackgroundAlt` bg, 16pt radius, 4pt padding
- Active: `spPrimary` bg, 20pt radius, `spSegment` in `spTextPrimary`
- Inactive: no bg, `spSegment` in `spTextSecondary`

### BadgeItem

- 56pt container, 1pt border, 16pt radius
- Earned: `spPrimaryLight` bg, `spPrimary` border, full opacity
- Locked: `spLockedBadgeBg` bg, `spBorder` border, 38% opacity
- Label: `spChartLabel` in `spTextSecondary`

### PrimaryCTA

- Full-width, `spPrimary` bg, ~52pt height, `SP.Radius.pill`
- Text: Nunito-ExtraBold ~16pt, `spTextPrimary`, optional trailing arrow

### SecondaryCTA

- Full-width, white bg, 2pt `spPrimary` border, ~52pt height, `SP.Radius.pill`

### CloseButton

- 40pt circle, `spBorder` bg at ~20% opacity, X icon, positioned top-right with 16pt inset

### XPBadge

- `spPrimaryLight` bg, `SP.Radius.pill`, HStack(flame icon 13pt + "0/195 XP" `spBody` ExtraBold)

---

## Screens

### 1. Home Screen

**Figma node:** `3:3` | **File:** `Features/Home/HomeView.swift`

**Layout (top to bottom):**

1. **Yellow header** (`spPrimary` bg, wavy bottom edge SVG)
   - Top bar: HStack — profile avatar (56pt circle, 2pt white border) | streak counter (flame + count, Nunito-Black 22.4pt white) | notification bell (44pt)
   - Greeting: "Good evening, {name}" — `spGreeting` in white@70%, centered
   - Title: "How do you feel?" — `spLargeTitle` in white, centered
2. **Mood check-in** (`spPrimary` bg)
   - 5 mood buttons, 16pt gap: Stressed, Sad, Neutral, Happy, Overwhelmed
   - Each: 64pt emoji container + label `spCaption` in white@50%
   - Wavy yellow-to-background SVG transition below
3. **Activities section** (`spBackground`)
   - Header: "Today's Activities" `spHeading` + subtitle | XPBadge
   - 4x ActivityCard, 12pt gap
   - Box Breathing (~2min, +30XP), Deep Focus (20min, +60XP), Coloring (5min, +25XP), Journal (30min, +80XP)
4. **Tab bar**

**Interactions:** Tap mood → record, tap activity play → present modal

**Data:** user profile, streak, today's XP, mood state, activity completion

---

### 2. Journey Screen (Week/Month/Year)

**Figma nodes:** `3:419`, `3:1076`, `3:1369` | **File:** `Features/Journey/JourneyView.swift`

**Layout:**

1. "Your Journey" `spPageTitle` + subtitle
2. SegmentedControl (Week/Month/Year)
3. **Chart card** (SectionCard):
   - "This Week" `spSectionTitle` + "On track" status in `spStatusText`
   - 7 vertical bars, rounded pill shape, day labels (M-S)
   - Bar fill levels: `spPrimary` (full), `spChartMedium` (partial), `spChartLight` (low), `spChartEmpty` (rest)
   - Legend: yellow dot = Active day, gray dot = Rest day
4. **StatsRow:** AVG/day | Best Streak | Total XP
5. **Activity Breakdown** (SectionCard): 2x2 grid with activity-specific bg colors, icon + count + label
6. Tab bar

**Data:** activity history by period, XP totals, streak, activity counts

---

### 3. Schedule Screen

**Figma node:** `3:1602` | **File:** `Features/Schedule/ScheduleView.swift`

**Layout:**

1. "Schedule" `spPageTitle` + "Self-care slotted into your day, automatically"
2. Calendar connect card: calendar icon + "Connect your calendar" + "Connect" button
3. Empty state until connected
4. Tab bar

**Data:** calendar integration status, suggested time slots

---

### 4. Profile Screen

**Figma node:** `3:825` | **File:** `Features/Profile/ProfileView.swift`

**Layout:**

1. "Profile" `spPageTitle` + subtitle
2. **Hero card** (SectionCard, overflow clip):
   - Yellow gradient bar (6pt, `spPrimary` → `#FFB800`)
   - Yellow bg with character SVG (100pt), radial white glow, level badge pill
   - Wavy yellow-to-white SVG
   - White section: name `spHeading` 19.2pt + "@handle . Joined {date}" `spSmallLabel`
3. **Overview** (SectionCard): 2x2 grid — Day Streak, Total XP, League, Activities
4. **Monthly Badges** (SectionCard): horizontal scroll of BadgeItems + "VIEW ALL"
5. **Activity Awards** (SectionCard): same layout as badges
6. Tab bar

**Data:** user profile, XP, level, streak, league, badges

---

### 5. Breathing Exercise

**Figma node:** `9:2` | **File:** `Features/Home/Activities/BreathingExerciseView.swift`

**Layout (modal, `spBackground`):**

1. CloseButton top-right
2. "CYCLE 1 OF 3" `spActivityLabel` + "Breathing Exercise" `spPageTitle`
3. Animated breathing circle (centered):
   - Outer: ~200pt, `spPrimaryLight` (scales with breath)
   - Inner: ~150pt, `spPrimary`
   - "Breathe out" `spCardTitle` + countdown `spLargeTitle`
4. 3 progress bars (completed/current/upcoming)

**Animation:** Scale up (inhale 4s) → hold (4s) → scale down (exhale 4s) → hold (4s), 3 cycles

---

### 6. Deep Focus (6-step flow)

**File:** `Features/Home/Activities/DeepFocusView.swift`

All steps: modal, `spBackground`, CloseButton top-right

**Step 1 — Task Input**: "DEEP FOCUS" label, "What do you need to work on?" title, large text area (white bg, 24pt radius, placeholder text), file upload section (supports multiple jpg/png/pdf/docx files, displayed as removable chips/thumbnails), "Analyze my task" PrimaryCTA. Files stored locally temporarily and erased after backend returns the task plan.

**Step 2 — Plan Review**: Backend returns a structured task breakdown (list of sub-tasks with time allocations totaling 20 min). Each item shows task title + allocated minutes. "Start focusing" PrimaryCTA, "Edit" text link (returns to Step 1 to refine prompt or add context). Mock data used until backend integration.

**Step 3 — Sound Check**: Lightweight checkpoint screen. "Have you set up your focus sounds?" title, brief instruction directing user to iOS Background Sounds (Control Center > Hearing > Background Sounds), "I'm ready" PrimaryCTA.

**Step 4 — Timer**: 240pt circular progress ring (`spBorder` track, `spPrimary` progress, 8pt stroke), "19:58 remaining" center text. Current task title animates in/out on the right side of the screen, transitioning to the next task as its allocated time elapses. Pause + "I'm done" buttons.

**Step 5 — Did you finish?**: Thinking emoji, "Did you finish?", "Yes, I'm done!" PrimaryCTA, "Add 5 more minutes" SecondaryCTA, "Resume where I left off" text link. "Yes" proceeds to Step 6, "Add 5 more minutes" extends timer and returns to Step 4, "Resume" returns to Step 4 at current position.

**Step 6 — Complete**: Reuses `ActivityCompleteView` (activityName: "Deep Focus", xpEarned: 60).

---

### 7. Coloring

**Figma node:** `11:1014` | **File:** `Features/Home/Activities/ColoringView.swift`

**Layout (modal, white bg):**

1. Header: close (left) | "COLORING" + "Mushroom Garden" | undo (right)
2. Canvas: white bg, 8pt radius, line drawing SVG, touch-to-fill regions
3. Color palette: 12 color dots (~28pt), horizontal scroll, selected = larger
4. Bottom: brush size selector (3 dots) | "Done" pill button

---

### 8. Journal

**Figma node:** `11:1332` | **File:** `Features/Home/Activities/JournalView.swift`

**Layout (modal, `spBackground`):**

1. Header: journal icon (32pt orange circle) | "Journal" + "30 min . +80 XP" | CloseButton
2. Prompt card: "What's one thing that went well today?" + "Next >" button
3. Text editor: white bg, 16pt radius, placeholder "Start writing here... there are no rules."
4. Bottom: "0 words" counter | "Finish session" button (activates when text entered)

### 9. Activity Completion State (Home Screen)

**Figma node:** `143:1893` | **File:** `Features/Home/HomeView.swift`, `DesignSystem/Components/ActivityCard.swift`

When an activity is completed, its card on the Home screen updates visually:

- **Yellow border:** `spPrimary` at 0.78pt
- **Yellow shadow:** `spPrimary` at 18% opacity (instead of black at 6%)
- **Icon container bg:** changes from `spBackground` to `spPrimaryLight`
- **Green checkmark:** `checkmark.circle.fill` in green appears next to the title
- **XP pill:** bg changes from `spPrimaryLight` to solid `spPrimary`
- **Play button:** chevron replaced with green checkmark, card disabled

---

### 10. App Loading

**Figma node:** `143:1863` | **File:** `Features/Onboarding/AppLoadingView.swift`

Splash/loading screen shown on app launch.

---

### 11. Register

**Figma nodes:** `142:232` (form), `142:410` (agreement check) | **File:** `Features/Onboarding/RegisterView.swift`

Registration form with agreement confirmation step.

---

### 12. MFA

**Figma nodes:** `142:310` (code entry), `142:358` (completion) | **File:** `Features/Onboarding/MFAView.swift`

Multi-factor authentication code entry and success confirmation.

---

### 13. Choose Character

**Figma nodes:** `142:742`, `143:995`, `143:1248` (one per character color) | **File:** `Features/Onboarding/ChooseCharacterView.swift`

Character selection grid with 4 character types (person, plant, bird, cat). Each shown in its signature color.

---

### 14. Customize Character

**Figma node:** `143:1754` | **File:** `Features/Onboarding/CustomizeCharacterView.swift`

Post-selection customization (color/variant options for the chosen character type).

---

## Implementation Order

### Phase 1: Foundation

1. Add new design tokens (colors, fonts, spacing) to existing token files
2. Build shared components: TabBarView, SectionCard, PrimaryCTA, SecondaryCTA, CloseButton, PillTag

### Phase 2: Core Tabs

3. Home screen (header, mood check-in, activity cards)
4. Journey screen (segmented control, chart, stats, breakdown)
5. Profile screen (hero card, overview, badges)
6. Schedule screen (empty state with calendar connect prompt)

### Phase 3: Activities

7. Breathing exercise (animated circle, timer logic, cycle progression)
8. Deep Focus (6-step flow: task input with file upload, plan review, sound check, timer with animated task progression, finish check, completion)
9. Journal (prompt cycling, text editor, word count, auto-save to SwiftData)
10. Coloring (canvas with touch regions, color palette, fill logic)

### Phase 4: Onboarding Flow

11. App loading / splash screen
12. Register screen (form fields + agreement check)
13. MFA screen (code entry + completion)
14. Choose character (character type selection grid)
15. Customize character (variant/color picker for chosen type)
16. Onboarding navigation coordinator (loading -> register -> MFA -> choose -> customize -> Home)

### Phase 5: Data & Integration

17. Wire up domain repositories to screens
18. Persist activity completion, mood entries, journal entries
19. XP calculation and streak tracking
20. Calendar integration (Schedule tab)

#### Journey chart refactor (Phase 5 prerequisite)

The Journey chart in `JourneyView.swift` currently uses hardcoded mock arrays where each bar carries its own pixel height and `Color` value. Before wiring backend data, refactor:

1. **Add domain type** in `Domain/Entities/`:
   ```swift
   struct ChartPoint: Sendable { let label: String; let activityCount: Int }
   struct JourneySnapshot: Sendable {
       let chartPoints: [ChartPoint]
       let avgPerDay: Double
       let bestStreakDays: Int
       let totalXP: Int
       let breakdown: [ActivityType: Int]
   }
   ```
2. **Extend `ActivityRepository`** with `func journeySnapshot(for period: JourneyPeriod) async -> JourneySnapshot`.
3. **Derive bar color + height in the view** from `activityCount` using a single rule (e.g., 0 -> `spChartEmpty`, 1-2 -> `spChartLight`, 3-4 -> `spChartMedium`, 5+ -> `spPrimary`; height = `activityCount / maxCount * chartMaxHeight`).
4. **Replace hardcoded `chartBars` / `currentStats` / `currentBreakdown`** with values derived from the fetched snapshot.

This keeps the raw `activityCount` (backend truth) separate from presentation (color/height) so a new threshold rule or chart height can change without touching data.
