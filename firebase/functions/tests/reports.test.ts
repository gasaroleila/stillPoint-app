import { getPeriodRange, getISOWeek, daysInPreviousMonth } from "../src/reports";

describe("getPeriodRange - week", () => {
  it("returns previous 7 days ending yesterday", () => {
    // Monday July 27, 2026 — report covers Mon Jul 20 to Sun Jul 26
    const monday = new Date(2026, 6, 27);
    const { start, end } = getPeriodRange(monday, "week");
    expect(start.getDate()).toBe(20);
    expect(start.getMonth()).toBe(6);
    expect(end.getDate()).toBe(26);
    expect(end.getMonth()).toBe(6);
    expect(start.getHours()).toBe(0);
    expect(end.getHours()).toBe(23);
  });

  it("generates correct week period key", () => {
    const monday = new Date(2026, 0, 5); // Jan 5 2026, Monday
    const { periodKey } = getPeriodRange(monday, "week");
    expect(periodKey).toMatch(/^2025-W\d{2}$|^2026-W\d{2}$/);
  });
});

describe("getPeriodRange - month", () => {
  it("returns previous month range", () => {
    // Aug 1 2026 — report covers July 2026
    const aug1 = new Date(2026, 7, 1);
    const { start, end, periodKey } = getPeriodRange(aug1, "month");
    expect(start.getFullYear()).toBe(2026);
    expect(start.getMonth()).toBe(6); // July
    expect(start.getDate()).toBe(1);
    expect(end.getMonth()).toBe(6);
    expect(end.getDate()).toBe(31); // July has 31 days
    expect(periodKey).toBe("2026-07");
  });

  it("handles February correctly", () => {
    // March 1 2026 — report covers Feb 2026
    const mar1 = new Date(2026, 2, 1);
    const { start, end, periodKey } = getPeriodRange(mar1, "month");
    expect(start.getMonth()).toBe(1); // Feb
    expect(end.getDate()).toBe(28); // 2026 is not a leap year
    expect(periodKey).toBe("2026-02");
  });

  it("handles January (wraps to previous year December)", () => {
    const jan1 = new Date(2026, 0, 1);
    const { start, end, periodKey } = getPeriodRange(jan1, "month");
    expect(start.getFullYear()).toBe(2025);
    expect(start.getMonth()).toBe(11); // December
    expect(end.getDate()).toBe(31);
    expect(periodKey).toBe("2025-12");
  });
});

describe("getISOWeek", () => {
  it("returns a valid week number for Jan 1 2026", () => {
    const week = getISOWeek(new Date(2026, 0, 1));
    expect(week).toBeGreaterThanOrEqual(0);
    expect(week).toBeLessThanOrEqual(53);
  });

  it("returns a valid week number for Dec 31 2026", () => {
    const week = getISOWeek(new Date(2026, 11, 31));
    expect(week).toBeGreaterThanOrEqual(50);
    expect(week).toBeLessThanOrEqual(53);
  });

  it("mid-year date returns expected week", () => {
    // July 1 2026 is a Wednesday — ISO week 27
    const week = getISOWeek(new Date(2026, 6, 1));
    expect(week).toBeGreaterThanOrEqual(26);
    expect(week).toBeLessThanOrEqual(28);
  });
});

describe("daysInPreviousMonth", () => {
  it("returns 31 for August (previous month is July)", () => {
    expect(daysInPreviousMonth(new Date(2026, 7, 15))).toBe(31);
  });

  it("returns 28 for March 2026 (Feb has 28 days)", () => {
    expect(daysInPreviousMonth(new Date(2026, 2, 1))).toBe(28);
  });

  it("returns 29 for March 2028 (leap year Feb)", () => {
    expect(daysInPreviousMonth(new Date(2028, 2, 1))).toBe(29);
  });

  it("returns 30 for July (previous month is June)", () => {
    expect(daysInPreviousMonth(new Date(2026, 6, 1))).toBe(30);
  });
});
