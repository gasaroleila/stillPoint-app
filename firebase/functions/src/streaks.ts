import { getFirestore, Timestamp } from "firebase-admin/firestore";

export const STREAK_MILESTONES = [7, 14, 30, 60, 180, 365];
export const MILESTONE_BONUS = 75;

export interface StreakResult {
  currentDays: number;
  longestDays: number;
  isMilestone: boolean;
  changed: boolean;
}

export function calculateStreak(
  previousDays: number,
  longestDays: number,
  lastActivityDate: Date | null,
  today: Date
): StreakResult {
  const startOfToday = new Date(today.getFullYear(), today.getMonth(), today.getDate());

  if (!lastActivityDate) {
    return { currentDays: 1, longestDays: Math.max(1, longestDays), isMilestone: false, changed: true };
  }

  const lastDate = new Date(
    lastActivityDate.getFullYear(),
    lastActivityDate.getMonth(),
    lastActivityDate.getDate()
  );
  const diffDays = Math.floor(
    (startOfToday.getTime() - lastDate.getTime()) / (1000 * 60 * 60 * 24)
  );

  if (diffDays === 0) {
    return { currentDays: previousDays, longestDays, isMilestone: false, changed: false };
  }

  const currentDays = diffDays === 1 ? previousDays + 1 : 1;
  const newLongest = Math.max(currentDays, longestDays);
  const isMilestone = STREAK_MILESTONES.includes(currentDays);

  return { currentDays, longestDays: newLongest, isMilestone, changed: true };
}

export async function updateStreak(userId: string): Promise<number> {
  const db = getFirestore();
  const streakRef = db.doc(`users/${userId}/streak/current`);
  const streakDoc = await streakRef.get();
  const streakData = streakDoc.data() ?? {
    currentDays: 0,
    longestDays: 0,
  };

  const now = new Date();
  const startOfToday = new Date(now.getFullYear(), now.getMonth(), now.getDate());
  const lastActivity = streakData.lastActivityDate?.toDate?.() ?? null;

  let currentDays = streakData.currentDays ?? 0;
  let bonusXP = 0;

  if (lastActivity) {
    const lastDate = new Date(
      lastActivity.getFullYear(),
      lastActivity.getMonth(),
      lastActivity.getDate()
    );
    const diffDays = Math.floor(
      (startOfToday.getTime() - lastDate.getTime()) / (1000 * 60 * 60 * 24)
    );

    if (diffDays === 0) {
      // Already logged today — no streak change
      return 0;
    } else if (diffDays === 1) {
      // Consecutive day
      currentDays += 1;
    } else {
      // Streak broken
      currentDays = 1;
    }
  } else {
    // First activity ever
    currentDays = 1;
  }

  const longestDays = Math.max(currentDays, streakData.longestDays ?? 0);

  // Check milestone bonuses
  if (STREAK_MILESTONES.includes(currentDays)) {
    bonusXP = MILESTONE_BONUS;

    // Award bonus XP to user profile
    const userRef = db.doc(`users/${userId}`);
    const userDoc = await userRef.get();
    const userData = userDoc.data() ?? {};
    await userRef.update({
      xp: (userData.xp ?? 0) + bonusXP,
      updatedAt: Timestamp.now(),
    });
  }

  await streakRef.set({
    currentDays,
    longestDays,
    lastActivityDate: Timestamp.now(),
  });

  return bonusXP;
}
