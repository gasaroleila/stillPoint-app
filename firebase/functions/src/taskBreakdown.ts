import { onCall, HttpsError } from "firebase-functions/v2/https";
import { defineSecret } from "firebase-functions/params";

const geminiApiKey = defineSecret("GEMINI_API_KEY");

// TODO: Replace Gemini with Claude API (claude-sonnet-5) once Anthropic API credits are funded.
// Swap the fetch URL, headers, body, and response parsing back to Anthropic format.
// See backend-planning.md for details.

export const analyzeTask = onCall(
  { secrets: [geminiApiKey] },
  async (request) => {
    const userId = request.auth?.uid;
    if (!userId) throw new HttpsError("unauthenticated", "Must be signed in.");

    const description = request.data?.description as string;
    if (!description || description.trim().length === 0) {
      throw new HttpsError("invalid-argument", "Task description is required.");
    }

    const apiKey = geminiApiKey.value();
    const url = `https://generativelanguage.googleapis.com/v1beta/models/gemini-3.5-flash:generateContent?key=${apiKey}`;

    const response = await fetch(url, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        contents: [
          {
            parts: [
              {
                text: `Break down this task into 3-5 focused steps that fit within 20 minutes total. Each step should have a clear title and a time allocation in minutes. The minutes must sum to exactly 20.

Task: ${description}

Respond with ONLY a JSON array, no other text. Example format:
[{"title": "Step name", "minutes": 5}, {"title": "Next step", "minutes": 5}]`,
              },
            ],
          },
        ],
        generationConfig: {
          responseMimeType: "application/json",
        },
      }),
    });

    if (!response.ok) {
      const errorText = await response.text();
      console.error("[analyzeTask] Gemini API error:", errorText);
      throw new HttpsError("internal", "Failed to analyze task.");
    }

    const result = (await response.json()) as {
      candidates?: { content?: { parts?: { text?: string }[] } }[];
    };
    const text = result.candidates?.[0]?.content?.parts?.[0]?.text ?? "[]";

    console.log("[analyzeTask] Input:", description);
    console.log("[analyzeTask] Gemini response:", text);

    try {
      const steps = JSON.parse(text) as { title: string; minutes: number }[];

      if (
        !Array.isArray(steps) ||
        steps.length === 0 ||
        !steps.every((s) => s.title && typeof s.minutes === "number")
      ) {
        console.error("[analyzeTask] Validation failed:", JSON.stringify(steps));
        throw new Error("Invalid format");
      }

      console.log("[analyzeTask] Parsed steps:", JSON.stringify(steps));
      return { steps };
    } catch (err) {
      console.error("[analyzeTask] Parse error:", err);
      return {
        steps: [
          { title: "Understand the problem", minutes: 4 },
          { title: "Research and plan", minutes: 5 },
          { title: "Execute", minutes: 7 },
          { title: "Review", minutes: 4 },
        ],
      };
    }
  }
);
