import { onSchedule } from "firebase-functions/v2/scheduler";
import { getFirestore, Timestamp } from "firebase-admin/firestore";

const ACTIVITY_TYPES = ["breathing", "focus", "coloring", "journaling"];

export const generateDailySuggestions = onSchedule(
  { schedule: "every day 06:00", timeZone: "America/New_York" },
  async () => {
    const db = getFirestore();
    const usersSnap = await db.collection("users").get();
    const today = new Date();
    const dateKey = today.toISOString().slice(0, 10);

    const yesterday = new Date(today);
    yesterday.setDate(yesterday.getDate() - 1);
    const yesterdayKey = yesterday.toISOString().slice(0, 10);

    for (const userDoc of usersSnap.docs) {
      const userId = userDoc.id;

      // Get yesterday's suggestions to diversify
      const yesterdaySuggDoc = await db
        .doc(`users/${userId}/suggestions/${yesterdayKey}`)
        .get();
      const yesterdayTypes = new Set<string>();

      if (yesterdaySuggDoc.exists) {
        const data = yesterdaySuggDoc.data();
        const activities = (data?.activities ?? []) as { activityType: string }[];
        for (const a of activities) {
          yesterdayTypes.add(a.activityType);
        }
      }

      // Pick 3 activities, preferring ones not done yesterday
      const available = ACTIVITY_TYPES.filter((t) => !yesterdayTypes.has(t));
      const pool = available.length >= 3 ? available : ACTIVITY_TYPES;
      const shuffled = pool.sort(() => Math.random() - 0.5);
      const picked = shuffled.slice(0, 3);

      const activities = picked.map((activityType) => ({
        activityType,
        status: "pending",
      }));

      await db.doc(`users/${userId}/suggestions/${dateKey}`).set({
        activities,
        generatedAt: Timestamp.now(),
      });
    }
  }
);
