import { getGrowthStage, BASE_XP } from "../src/xp";

describe("getGrowthStage", () => {
  it("returns newborn for 0 XP", () => {
    expect(getGrowthStage(0)).toBe("newborn");
  });

  it("returns newborn for 200 XP", () => {
    expect(getGrowthStage(200)).toBe("newborn");
  });

  it("returns sprouting for 201 XP", () => {
    expect(getGrowthStage(201)).toBe("sprouting");
  });

  it("returns sprouting for 1500 XP", () => {
    expect(getGrowthStage(1500)).toBe("sprouting");
  });

  it("returns young for 1501 XP", () => {
    expect(getGrowthStage(1501)).toBe("young");
  });

  it("returns young for 8000 XP", () => {
    expect(getGrowthStage(8000)).toBe("young");
  });

  it("returns mature for 8001 XP", () => {
    expect(getGrowthStage(8001)).toBe("mature");
  });

  it("returns mature for 20000 XP", () => {
    expect(getGrowthStage(20000)).toBe("mature");
  });
});

describe("BASE_XP", () => {
  it("has correct XP for breathing", () => {
    expect(BASE_XP["breathing"]).toBe(20);
  });

  it("has correct XP for journaling", () => {
    expect(BASE_XP["journaling"]).toBe(25);
  });

  it("has correct XP for coloring", () => {
    expect(BASE_XP["coloring"]).toBe(30);
  });

  it("has correct XP for focus", () => {
    expect(BASE_XP["focus"]).toBe(50);
  });
});
