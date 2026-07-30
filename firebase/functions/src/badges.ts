import { getFirestore, Timestamp } from "firebase-admin/firestore";

export interface BadgeRule {
  id: string;
  name: string;
  description: string;
  check: (context: BadgeContext) => boolean;
}

export interface BadgeContext {
  totalActivities: number;
  xp: number;
  streakDays: number;
  activityType: string;
  completionsByType: Record<string, number>;
}

export const BADGE_RULES: BadgeRule[] = [
  {
    id: "first-steps",
    name: "First Steps",
    description: "Complete your first activity",
    check: (ctx) => ctx.totalActivities >= 1,
  },
  {
    id: "streak-7",
    name: "Week Warrior",
    description: "Maintain a 7-day streak",
    check: (ctx) => ctx.streakDays >= 7,
  },
  {
    id: "streak-30",
    name: "Monthly Master",
    description: "Maintain a 30-day streak",
    check: (ctx) => ctx.streakDays >= 30,
  },
  {
    id: "breath-master",
    name: "Breath Master",
    description: "Complete 10 breathing exercises",
    check: (ctx) => (ctx.completionsByType["breathing"] ?? 0) >= 10,
  },
  {
    id: "focus-champion",
    name: "Focus Champion",
    description: "Complete 10 focus sessions",
    check: (ctx) => (ctx.completionsByType["focus"] ?? 0) >= 10,
  },
  {
    id: "journal-keeper",
    name: "Journal Keeper",
    description: "Write 10 journal entries",
    check: (ctx) => (ctx.completionsByType["journaling"] ?? 0) >= 10,
  },
  {
    id: "color-artist",
    name: "Color Artist",
    description: "Complete 10 coloring sessions",
    check: (ctx) => (ctx.completionsByType["coloring"] ?? 0) >= 10,
  },
  {
    id: "xp-500",
    name: "Rising Star",
    description: "Earn 500 XP",
    check: (ctx) => ctx.xp >= 500,
  },
  {
    id: "xp-5000",
    name: "XP Hunter",
    description: "Earn 5,000 XP",
    check: (ctx) => ctx.xp >= 5000,
  },
  {
    id: "all-rounder",
    name: "All-Rounder",
    description: "Complete every activity type at least once",
    check: (ctx) => {
      const types = ["breathing", "focus", "coloring", "journaling"];
      return types.every((t) => (ctx.completionsByType[t] ?? 0) >= 1);
    },
  },
];

export function evaluateBadges(
  context: BadgeContext,
  alreadyEarned: Set<string>
): BadgeRule[] {
  return BADGE_RULES.filter(
    (rule) => !alreadyEarned.has(rule.id) && rule.check(context)
  );
}

export async function checkBadges(
  userId: string,
  activityType: string
): Promise<void> {
  const db = getFirestore();

  // Gather context
  const userDoc = await db.doc(`users/${userId}`).get();
  const userData = userDoc.data() ?? {};
  const streakDoc = await db.doc(`users/${userId}/streak/current`).get();
  const streakData = streakDoc.data() ?? {};

  // Count completions by type
  const completionsSnap = await db
    .collection(`users/${userId}/completions`)
    .get();
  const completionsByType: Record<string, number> = {};
  for (const doc of completionsSnap.docs) {
    const type = doc.data().activityType as string;
    completionsByType[type] = (completionsByType[type] ?? 0) + 1;
  }

  const context: BadgeContext = {
    totalActivities: userData.totalActivities ?? 0,
    xp: userData.xp ?? 0,
    streakDays: streakData.currentDays ?? 0,
    activityType,
    completionsByType,
  };

  // Check existing badges
  const badgesSnap = await db.collection(`users/${userId}/badges`).get();
  const earnedBadgeIds = new Set(badgesSnap.docs.map((d) => d.id));

  // Award new badges
  const batch = db.batch();
  let awarded = false;

  for (const rule of BADGE_RULES) {
    if (earnedBadgeIds.has(rule.id)) continue;
    if (!rule.check(context)) continue;

    const badgeRef = db.doc(`users/${userId}/badges/${rule.id}`);
    batch.set(badgeRef, {
      name: rule.name,
      description: rule.description,
      earnedAt: Timestamp.now(),
    });
    awarded = true;
  }

  if (awarded) {
    await batch.commit();
  }
}
