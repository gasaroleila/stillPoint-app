Wellness suggestions working

Pull history — for each activity type (Box Breathing, Journal, Coloring, Deep Focus), find the last date the user completed it.
Rank by recency — activities not done in the longest time get priority for today's suggestions.
Fit to calendar slots — cross-reference that ranked list against available free slots (from the FreeBusy computation) — e.g., Deep Focus only gets suggested if there's a 20+ min gap available.
 - OAuth connect → get calendar ID(s)
 - Query freeBusy for the next day/week
 - Invert busy blocks against a reasonable daily window to get free slots
 - Match slot durations to activity durations (Deep Focus needs a 20+ min slot, Box Breathing fits in any gap)
Pick 3 — take the top-ranked, slot-compatible activities. If someone did Journal and Coloring yesterday but not Box Breathing or Deep Focus in 3 days, those two get bumped to the top today.
Compare to yesterday — after picking today's 3, check overlap with yesterday's 3. If at least 1 differs, the diversity bonus (+25 XP) triggers when completed.

## Frontend Plan - NEXT

### App Flow

## Backend Plan
