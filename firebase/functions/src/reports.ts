import { onSchedule } from "firebase-functions/v2/scheduler";
import { getFirestore, Timestamp } from "firebase-admin/firestore";

export const computeWeeklyReport = onSchedule(
  { schedule: "every monday 02:00", timeZone: "America/New_York" },
  async () => {
    await computeReports("week");
  }
);

export const computeMonthlyReport = onSchedule(
  { schedule: "1 of month 02:00", timeZone: "America/New_York" },
  async () => {
    await computeReports("month");
  }
);

async function computeReports(period: "week" | "month"): Promise<void> {
  const db = getFirestore();
  const usersSnap = await db.collection("users").get();
  const now = new Date();

  for (const userDoc of usersSnap.docs) {
    const userId = userDoc.id;

    const { start, end, periodKey } = getPeriodRange(now, period);

    // Get completions in range
    const completionsSnap = await db
      .collection(`users/${userId}/completions`)
      .where("completedAt", ">=", Timestamp.fromDate(start))
      .where("completedAt", "<=", Timestamp.fromDate(end))
      .get();

    // Get moods in range
    const moodsSnap = await db
      .collection(`users/${userId}/moods`)
      .where("date", ">=", Timestamp.fromDate(start))
      .where("date", "<=", Timestamp.fromDate(end))
      .get();

    // Count completions per day
    const dailyCounts: Record<string, number> = {};
    for (const doc of completionsSnap.docs) {
      const date = doc.data().completedAt?.toDate?.();
      if (date) {
        const key = date.toISOString().slice(0, 10);
        dailyCounts[key] = (dailyCounts[key] ?? 0) + 1;
      }
    }
    // Also mark mood-only days as active (count 0 completions but still active)
    for (const doc of moodsSnap.docs) {
      const date = doc.data().date?.toDate?.();
      if (date) {
        const key = date.toISOString().slice(0, 10);
        if (!(key in dailyCounts)) dailyCounts[key] = 0;
      }
    }

    // Build dailyActivity array covering every day in the period
    const dailyActivity: { date: string; count: number }[] = [];
    const cursor = new Date(start);
    while (cursor <= end) {
      const key = cursor.toISOString().slice(0, 10);
      dailyActivity.push({ date: key, count: dailyCounts[key] ?? 0 });
      cursor.setDate(cursor.getDate() + 1);
    }

    const totalDays = dailyActivity.length;
    const activeDays = dailyActivity.filter((d) => d.count > 0).length;
    const restDays = totalDays - activeDays;

    // Count moods by type
    const moodBreakdown: Record<string, number> = {};
    for (const doc of moodsSnap.docs) {
      const mood = doc.data().mood as string;
      if (mood) moodBreakdown[mood] = (moodBreakdown[mood] ?? 0) + 1;
    }

    // Total XP and activity breakdown from completions
    let totalXP = 0;
    const activityBreakdown: Record<string, number> = {};
    for (const doc of completionsSnap.docs) {
      const data = doc.data();
      totalXP += data.xpAwarded ?? 0;
      const type = data.activityType as string;
      activityBreakdown[type] = (activityBreakdown[type] ?? 0) + 1;
    }

    // Best streak in period
    const streakDoc = await db.doc(`users/${userId}/streak/current`).get();
    const bestStreak = streakDoc.data()?.longestDays ?? 0;

    await db.doc(`users/${userId}/reports/${periodKey}`).set({
      activeDays,
      restDays,
      totalXP,
      bestStreak,
      activityBreakdown,
      moodBreakdown,
      dailyActivity,
      computedAt: Timestamp.now(),
    });
  }
}

export function getPeriodRange(
  now: Date,
  period: "week" | "month"
): { start: Date; end: Date; periodKey: string } {
  if (period === "week") {
    const end = new Date(now);
    end.setDate(end.getDate() - 1); // yesterday (report runs Monday for prior week)
    const start = new Date(end);
    start.setDate(start.getDate() - 6);
    start.setHours(0, 0, 0, 0);
    end.setHours(23, 59, 59, 999);

    const weekNum = getISOWeek(start);
    const year = start.getFullYear();
    const periodKey = `${year}-W${String(weekNum).padStart(2, "0")}`;
    return { start, end, periodKey };
  } else {
    const lastMonth = new Date(now.getFullYear(), now.getMonth() - 1, 1);
    const start = new Date(lastMonth.getFullYear(), lastMonth.getMonth(), 1);
    const end = new Date(lastMonth.getFullYear(), lastMonth.getMonth() + 1, 0, 23, 59, 59, 999);
    const periodKey = `${start.getFullYear()}-${String(start.getMonth() + 1).padStart(2, "0")}`;
    return { start, end, periodKey };
  }
}

export function getISOWeek(date: Date): number {
  const d = new Date(date);
  d.setHours(0, 0, 0, 0);
  d.setDate(d.getDate() + 3 - ((d.getDay() + 6) % 7));
  const yearStart = new Date(d.getFullYear(), 0, 4);
  return Math.ceil(((d.getTime() - yearStart.getTime()) / 86400000 + 1) / 7);
}

export function daysInPreviousMonth(now: Date): number {
  return new Date(now.getFullYear(), now.getMonth(), 0).getDate();
}
