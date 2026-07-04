# StillPoint Wellness App

*Created: 2026-06-19*

## App Description

StillPoint is a mindfulness and wellness app focused on building daily habits that prevent burnout and maintains the user's mental health. The app is designed to be a daily companion in its gamification approach, where users  gain points and grow app characters by completing wellness activities. The app has to be seemless, visually delightful to users, and be built in a way that it becomes part of their daily routine.

## Features

### Feature 1: Authentication & Authorization

This feature allows users to create an account if it's their first time, login if they already have an account and be able to reset their password. Authentication is only done using a password they create no signing in with third party accounts. It should also involve a multi-factor authentication as a code sent to their phone number.

Information gathered while creating account:

- Username
- Email
- Date of birth
- Agreement to our mental health policy
- Agreement that this app should not replace their actual therapy and they should call for help in case of an emergency.

### Feature 2: Gamification

The whole app is tied to this feature. This is a feature that presents a user with a character that they develop by enganging with the app. Every wellness activity done contributes to points that accumulate to lead to the character's growth.

#### 2.1 Character Selection

This is the sub-feature where they initially choose among the available characters according to their preferences. This feature entices the user, by showing them cool things they can unlock for each character. The user's character preference is saved and reflected in the main app.

##### These are the available characters:

| Character name | Description                                                    |  |
| -------------- | --------------------------------------------------------------  |
| `Person`     | A human cartoon that comes in all skin shades, and all genders |
| `Plant`      | A representation of a tree with green leaves                   |
| `Bird`       | A domestic yellow canary bird                                  |
| `Cat`        | A domestic shorthair cat breed                                 |

---

#### 2.2 Character Growth

The chosen character grows as the user gains more points from doing wellness activities in the app. There's two ways a user can grow their character: daily consistency, and diversifying the activities they do over time. A point system will be used to measure user activity progress and if they attain enough points they'll be promoted to another growth stage.

##### Daily Structure

- Each day, the system suggests **3 wellness activities** with time slots based on the user's calendar
- The user can accept, swap, or skip suggestions
- Login + mood check-in is always available and doesn't count toward the 3
- The suggestion engine (separate feature) handles activity diversification across days

---

##### XP Earning Model

| Activity Type | XP Awarded | Notes |
|---|---|---|
| Daily login + mood check-in | +5 XP | Always available, outside the 3 daily activities |
| Box Breathing (~2 min) | +20 XP | |
| Journal (~10 min) | +25 XP | |
| Coloring (~5 min) | +30 XP | |
| Deep Focus (20+ min) | +50 XP | |
| Diversity bonus | +25 XP | Awarded when today's activities differ from yesterday's (handled by suggestion engine) |

**Max daily XP** (3 highest activities + login + diversity): 50 + 30 + 25 + 5 + 25 = **135 XP/day**

**Typical daily XP** (mixed selection, not always diverse): ~80-100 XP/day

---

##### Growth Stages & XP Thresholds

| Stage | Timeframe | XP Required | Notes |
|---|---|---|---|
| `Newborn` | Day 0-6 | 0-200 XP | ~2-3 active days to complete |
| `Sprouting` | Week 1-4 | 201-1,500 XP | ~2-3 weeks of regular activity |
| `Young` | Month 1-5 | 1,501-8,000 XP | Longest window, requires sustained engagement |
| `Mature` | Month 6-12 | 8,001-20,000 XP | Requires months of consistent activity |

##### Pacing Math

- **Max-effort user** (every day, diversity bonus): ~131 XP/day → 20,000 XP in ~153 days (~5 months)
- **Consistent user** (5 days/week, some diversity): ~90 XP × 5 = 450 XP/week → 20,000 XP in ~44 weeks (~10 months)
- **Casual user** (3-4 days/week): ~75 XP × 3.5 = 263 XP/week → 20,000 XP in ~76 weeks (~17 months)

*Note: Streak milestones add up to 450 XP total over the year, a small boost on top of daily earning.*

---

##### Streak Milestone Rewards

One-time +75 XP awarded at each consistency milestone.

| Milestone |
|---|
| 7-day streak |
| 14-day streak |
| 30-day streak |
| 60-day streak |
| 180-day streak |
| 365-day streak |

**Total streak XP (all milestones):** 6 × 75 = **450 XP**

---

##### Design Rules

- **XP only goes up** — stages are permanent, users never regress
- **3 activities per day** — system-suggested, user-confirmed
- **No daily XP cap** — the 3-activity limit handles pacing naturally
- **Diversity is system-managed** — the suggestion engine rotates activities across days (separate feature)
- **Streak bonuses are one-time** — loyalty rewards, not farmable
- **Newborn is intentionally quick** — early wins build the habit


### Feature 3: Main Wellness Activities
This is the core activities/tasks a user can complete to improve their wellbeing instantly, the activities are designed to be brief and each completes one specific thing. As part of the MVP there are only 4 activities.

| Activity Name         | Duration  | Description                |
| ------------- | ---------- | ------------------------------- |
| `Box Breathing`   | ~ 2mins    | Breathing in and out in patterns to calm yourself     |
| `Deep Focus` | 20mins minimum   | Time to focus on one specific chunk of task that a user can complete in 20 mins. The user mentions what they want to finish and that time is dedicated to doing it.   |
| `Coloring`     | ~ 5mins  | They're given drawings (like in a children coloring book) that match their app character and they color it. However, any drawing that's relevant to their app character is a potential drawing|
| `Journal`    | ~10 mins| A blank space or continuing where they left off(journal pages are saved), this is an activity to jot down what they have on their mind.       |

---

### Feature 4: Wellness Activity Suggestions
It allows users to connect their normal calendars to the app, for the app to automatically find free time slots and suggest 3 daily activites that are diversified across days. They can accept, swap, or skip suggestions(when they skip they manually choose their 3 daily activities). If an activity is accepted a reminder notification will be sent to the user 5 minutes before its scheduled time.

### Feature 5: Mood Check-in
A daily prompt that asks a user how they feel to collect data that will be used in reports.

### Feature 6: Profile Report
A report features that summarizes user's progress weekly, monthly and yearly. It informs the user of their active days/rest days, offers general overview ex best streak, total XP, etc and activity breakdown count ex how many Deep Focus they did montly, yearly or weekly.

## Frontend Plan
Find frontend-planning.md file for details.