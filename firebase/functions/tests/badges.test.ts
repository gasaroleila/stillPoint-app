import { evaluateBadges, BADGE_RULES, BadgeContext } from "../src/badges";

function makeContext(overrides: Partial<BadgeContext> = {}): BadgeContext {
  return {
    totalActivities: 0,
    xp: 0,
    streakDays: 0,
    activityType: "breathing",
    completionsByType: {},
    ...overrides,
  };
}

describe("evaluateBadges", () => {
  it("awards first-steps on first activity", () => {
    const ctx = makeContext({ totalActivities: 1 });
    const earned = evaluateBadges(ctx, new Set());
    expect(earned.map((b) => b.id)).toContain("first-steps");
  });

  it("does not re-award already earned badges", () => {
    const ctx = makeContext({ totalActivities: 1 });
    const earned = evaluateBadges(ctx, new Set(["first-steps"]));
    expect(earned.map((b) => b.id)).not.toContain("first-steps");
  });

  it("awards streak-7 at 7 days", () => {
    const ctx = makeContext({ streakDays: 7 });
    const earned = evaluateBadges(ctx, new Set());
    expect(earned.map((b) => b.id)).toContain("streak-7");
  });

  it("awards streak-30 at 30 days", () => {
    const ctx = makeContext({ streakDays: 30 });
    const earned = evaluateBadges(ctx, new Set());
    const ids = earned.map((b) => b.id);
    expect(ids).toContain("streak-30");
    expect(ids).toContain("streak-7"); // also qualifies
  });

  it("awards breath-master at 10 breathing completions", () => {
    const ctx = makeContext({ completionsByType: { breathing: 10 } });
    const earned = evaluateBadges(ctx, new Set());
    expect(earned.map((b) => b.id)).toContain("breath-master");
  });

  it("does not award breath-master at 9 completions", () => {
    const ctx = makeContext({ completionsByType: { breathing: 9 } });
    const earned = evaluateBadges(ctx, new Set());
    expect(earned.map((b) => b.id)).not.toContain("breath-master");
  });

  it("awards focus-champion at 10 focus sessions", () => {
    const ctx = makeContext({ completionsByType: { focus: 10 } });
    const earned = evaluateBadges(ctx, new Set());
    expect(earned.map((b) => b.id)).toContain("focus-champion");
  });

  it("awards journal-keeper at 10 journaling entries", () => {
    const ctx = makeContext({ completionsByType: { journaling: 10 } });
    const earned = evaluateBadges(ctx, new Set());
    expect(earned.map((b) => b.id)).toContain("journal-keeper");
  });

  it("awards color-artist at 10 coloring sessions", () => {
    const ctx = makeContext({ completionsByType: { coloring: 10 } });
    const earned = evaluateBadges(ctx, new Set());
    expect(earned.map((b) => b.id)).toContain("color-artist");
  });

  it("awards xp-500 at 500 XP", () => {
    const ctx = makeContext({ xp: 500 });
    const earned = evaluateBadges(ctx, new Set());
    expect(earned.map((b) => b.id)).toContain("xp-500");
  });

  it("awards xp-5000 at 5000 XP", () => {
    const ctx = makeContext({ xp: 5000 });
    const earned = evaluateBadges(ctx, new Set());
    const ids = earned.map((b) => b.id);
    expect(ids).toContain("xp-5000");
    expect(ids).toContain("xp-500");
  });

  it("awards all-rounder when all types completed", () => {
    const ctx = makeContext({
      completionsByType: { breathing: 1, focus: 1, coloring: 1, journaling: 1 },
    });
    const earned = evaluateBadges(ctx, new Set());
    expect(earned.map((b) => b.id)).toContain("all-rounder");
  });

  it("does not award all-rounder with missing type", () => {
    const ctx = makeContext({
      completionsByType: { breathing: 1, focus: 1, coloring: 1 },
    });
    const earned = evaluateBadges(ctx, new Set());
    expect(earned.map((b) => b.id)).not.toContain("all-rounder");
  });

  it("returns empty array when nothing qualifies", () => {
    const ctx = makeContext();
    const earned = evaluateBadges(ctx, new Set());
    expect(earned).toEqual([]);
  });
});

describe("BADGE_RULES", () => {
  it("has 10 rules", () => {
    expect(BADGE_RULES).toHaveLength(10);
  });

  it("all rules have unique ids", () => {
    const ids = BADGE_RULES.map((r) => r.id);
    expect(new Set(ids).size).toBe(ids.length);
  });
});
