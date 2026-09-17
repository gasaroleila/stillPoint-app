import { calculateStreak, STREAK_MILESTONES, MILESTONE_BONUS } from "../src/streaks";

describe("calculateStreak", () => {
  const today = new Date(2026, 6, 30); // July 30, 2026

  it("returns 1 day for first activity ever", () => {
    const result = calculateStreak(0, 0, null, today);
    expect(result.currentDays).toBe(1);
    expect(result.longestDays).toBe(1);
    expect(result.changed).toBe(true);
  });

  it("increments streak for consecutive day", () => {
    const yesterday = new Date(2026, 6, 29);
    const result = calculateStreak(5, 5, yesterday, today);
    expect(result.currentDays).toBe(6);
    expect(result.longestDays).toBe(6);
    expect(result.changed).toBe(true);
  });

  it("does not change streak for same day activity", () => {
    const result = calculateStreak(5, 5, today, today);
    expect(result.currentDays).toBe(5);
    expect(result.changed).toBe(false);
  });

  it("resets streak after missing a day", () => {
    const twoDaysAgo = new Date(2026, 6, 28);
    const result = calculateStreak(10, 10, twoDaysAgo, today);
    expect(result.currentDays).toBe(1);
    expect(result.longestDays).toBe(10);
    expect(result.changed).toBe(true);
  });

  it("resets streak after missing many days", () => {
    const weekAgo = new Date(2026, 6, 23);
    const result = calculateStreak(15, 15, weekAgo, today);
    expect(result.currentDays).toBe(1);
    expect(result.longestDays).toBe(15);
  });

  it("preserves longest days when current is less", () => {
    const yesterday = new Date(2026, 6, 29);
    const result = calculateStreak(3, 20, yesterday, today);
    expect(result.currentDays).toBe(4);
    expect(result.longestDays).toBe(20);
  });

  it("updates longest days when current exceeds it", () => {
    const yesterday = new Date(2026, 6, 29);
    const result = calculateStreak(20, 20, yesterday, today);
    expect(result.currentDays).toBe(21);
    expect(result.longestDays).toBe(21);
  });

  it("flags milestone at 7 days", () => {
    const yesterday = new Date(2026, 6, 29);
    const result = calculateStreak(6, 6, yesterday, today);
    expect(result.currentDays).toBe(7);
    expect(result.isMilestone).toBe(true);
  });

  it("flags milestone at 30 days", () => {
    const yesterday = new Date(2026, 6, 29);
    const result = calculateStreak(29, 29, yesterday, today);
    expect(result.currentDays).toBe(30);
    expect(result.isMilestone).toBe(true);
  });

  it("does not flag milestone at 8 days", () => {
    const yesterday = new Date(2026, 6, 29);
    const result = calculateStreak(7, 7, yesterday, today);
    expect(result.currentDays).toBe(8);
    expect(result.isMilestone).toBe(false);
  });
});

describe("constants", () => {
  it("has correct milestones", () => {
    expect(STREAK_MILESTONES).toEqual([7, 14, 30, 60, 180, 365]);
  });

  it("milestone bonus is 75", () => {
    expect(MILESTONE_BONUS).toBe(75);
  });
});
