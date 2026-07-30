const GROWTH_STAGES: { threshold: number; stage: string }[] = [
  { threshold: 0, stage: "newborn" },
  { threshold: 201, stage: "sprouting" },
  { threshold: 1501, stage: "young" },
  { threshold: 8001, stage: "mature" },
];

export const BASE_XP: Record<string, number> = {
  breathing: 20,
  journaling: 25,
  coloring: 30,
  focus: 50,
};

export function getGrowthStage(xp: number): string {
  for (let i = GROWTH_STAGES.length - 1; i >= 0; i--) {
    if (xp >= GROWTH_STAGES[i].threshold) {
      return GROWTH_STAGES[i].stage;
    }
  }
  return "newborn";
}
