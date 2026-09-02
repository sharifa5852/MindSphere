const test = require("node:test");
const assert = require("node:assert/strict");

const { calculateAssessmentResult } = require("../src/utils/assessmentScoring");

test("PHQ-9 calculates score and support flags", () => {
  const result = calculateAssessmentResult("phq9", [0, 0, 0, 0, 0, 0, 0, 0, 1]);
  assert.equal(result.score, 1);
  assert.equal(result.level, "minimal");
  assert.equal(result.needsSupportPrompt, true);
});

test("GAD-7 calculates moderate result and professional-support prompt", () => {
  const result = calculateAssessmentResult("gad7", [2, 2, 2, 2, 2, 0, 0]);
  assert.equal(result.score, 10);
  assert.equal(result.level, "moderate");
  assert.equal(result.considerProfessionalSupport, true);
});
