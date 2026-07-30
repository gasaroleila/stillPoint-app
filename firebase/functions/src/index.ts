import { initializeApp } from "firebase-admin/app";
import { onDocumentCreated } from "firebase-functions/v2/firestore";
import { getFirestore, Timestamp } from "firebase-admin/firestore";
import { updateStreak } from "./streaks";
import { checkBadges } from "./badges";
import { getGrowthStage, BASE_XP } from "./xp";

initializeApp();

// Triggered when a user completes an activity
export const onActivityCompleted = onDocumentCreated(
  "users/{userId}/completions/{completionId}",
  async (event) => {
    const snapshot = event.data;
    if (!snapshot) return;

    const db = getFirestore();
    const userId = event.params.userId;
    const completionData = snapshot.data();
    const activityType = completionData.activityType as string;

    // 1. Calculate base XP
    let xpAwarded = BASE_XP[activityType] ?? 20;

    // 2. Diversity bonus: +25 if this activity type differs from yesterday's
    const yesterday = new Date();
    yesterday.setDate(yesterday.getDate() - 1);
    const startOfYesterday = new Date(yesterday.getFullYear(), yesterday.getMonth(), yesterday.getDate());
    const endOfYesterday = new Date(startOfYesterday.getTime() + 86400000 - 1);

    const yesterdayCompletions = await db
      .collection(`users/${userId}/completions`)
      .where("completedAt", ">=", Timestamp.fromDate(startOfYesterday))
      .where("completedAt", "<=", Timestamp.fromDate(endOfYesterday))
      .get();

    const yesterdayTypes = new Set(
      yesterdayCompletions.docs.map((d) => d.data().activityType)
    );

    if (yesterdayTypes.size > 0 && !yesterdayTypes.has(activityType)) {
      xpAwarded += 25;
    }

    // 3. Update completion doc with calculated XP
    await snapshot.ref.update({ xpAwarded });

    // 4. Update streak
    const streakBonus = await updateStreak(userId);
    xpAwarded += streakBonus;

    // 5. Update user profile
    const userRef = db.collection("users").doc(userId);
    const userDoc = await userRef.get();
    const userData = userDoc.data() ?? {};
    const newXP = (userData.xp ?? 0) + xpAwarded;
    const newTotal = (userData.totalActivities ?? 0) + 1;

    await userRef.update({
      xp: newXP,
      totalActivities: newTotal,
      growthStage: getGrowthStage(newXP),
      updatedAt: Timestamp.now(),
    });

    // 6. Check badge criteria
    await checkBadges(userId, activityType);
  }
);

// Triggered when a user logs a mood
export const onMoodLogged = onDocumentCreated(
  "users/{userId}/moods/{moodId}",
  async (event) => {
    const snapshot = event.data;
    if (!snapshot) return;

    const db = getFirestore();
    const userId = event.params.userId;

    // Award +5 XP for first mood entry today
    const now = new Date();
    const startOfToday = new Date(now.getFullYear(), now.getMonth(), now.getDate());
    const endOfToday = new Date(startOfToday.getTime() + 86400000 - 1);

    const todayMoods = await db
      .collection(`users/${userId}/moods`)
      .where("date", ">=", Timestamp.fromDate(startOfToday))
      .where("date", "<=", Timestamp.fromDate(endOfToday))
      .get();

    // Only award XP for the first mood of the day
    if (todayMoods.size > 1) return;

    const dailyXP = 5;
    const userRef = db.collection("users").doc(userId);
    const userDoc = await userRef.get();
    const userData = userDoc.data() ?? {};
    const newXP = (userData.xp ?? 0) + dailyXP;

    await userRef.update({
      xp: newXP,
      growthStage: getGrowthStage(newXP),
      updatedAt: Timestamp.now(),
    });

    // Update streak for mood logging too
    await updateStreak(userId);
  }
);

// Re-export scheduled functions
export { generateDailySuggestions } from "./suggestions";
export { computeWeeklyReport, computeMonthlyReport } from "./reports";
