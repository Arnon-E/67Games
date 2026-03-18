import * as admin from "firebase-admin";
import * as functions from "firebase-functions";

admin.initializeApp();

const db = admin.firestore();

// All game mode IDs that have leaderboards.
const GAME_MODES = [
  "classic",
  "extended",
  "blind",
  "reverse",
  "reverse100",
  "daily",
  "surge",
  "doubletap",
  "movingtarget",
  "calibration",
  "pressure",
];

/**
 * Returns an ISO week identifier string like "2024-W03" for archiving.
 */
function getWeekId(date: Date): string {
  const d = new Date(Date.UTC(date.getFullYear(), date.getMonth(), date.getDate()));
  // ISO week: Thursday in current week determines the year.
  d.setUTCDate(d.getUTCDate() + 4 - (d.getUTCDay() || 7));
  const year = d.getUTCFullYear();
  const startOfYear = new Date(Date.UTC(year, 0, 1));
  const weekNo = Math.ceil(
    ((d.getTime() - startOfYear.getTime()) / 86400000 + 1) / 7
  );
  return `${year}-W${String(weekNo).padStart(2, "0")}`;
}

/**
 * Archives all scores for a given mode into leaderboard_history/{weekId}/{modeId}/scores/
 * then deletes them from leaderboard/{modeId}/scores/.
 * Uses batched writes (max 500 ops per batch).
 */
async function resetModeLeaderboard(modeId: string, weekId: string): Promise<void> {
  const scoresRef = db
    .collection("leaderboard")
    .doc(modeId)
    .collection("scores");

  const snapshot = await scoresRef.get();
  if (snapshot.empty) return;

  const archiveRef = db
    .collection("leaderboard_history")
    .doc(weekId)
    .collection(modeId);

  // Process in batches of 250 (archive write + delete write = 2 ops per doc).
  const docs = snapshot.docs;
  for (let i = 0; i < docs.length; i += 250) {
    const batch = db.batch();
    const chunk = docs.slice(i, i + 250);

    for (const doc of chunk) {
      // Archive the score.
      batch.set(archiveRef.doc(doc.id), {
        ...doc.data(),
        archivedAt: admin.firestore.FieldValue.serverTimestamp(),
      });
      // Delete from active leaderboard.
      batch.delete(scoresRef.doc(doc.id));
    }

    await batch.commit();
  }

  // Update metadata on the leaderboard document.
  await db.collection("leaderboard").doc(modeId).set(
    {
      lastResetAt: admin.firestore.FieldValue.serverTimestamp(),
      lastArchivedWeek: weekId,
    },
    {merge: true}
  );
}

/**
 * Scheduled Cloud Function – runs every Monday at 00:00 UTC.
 * Archives the previous week's scores and clears all leaderboards
 * so the new week starts fresh.
 */
export const weeklyLeaderboardReset = functions.pubsub
  .schedule("0 0 * * 1") // every Monday at midnight UTC
  .timeZone("UTC")
  .onRun(async (_context) => {
    const now = new Date();
    // The week being archived is the one that just ended (last week).
    const lastWeek = new Date(now.getTime() - 7 * 24 * 60 * 60 * 1000);
    const weekId = getWeekId(lastWeek);

    functions.logger.info(`Starting weekly leaderboard reset. Archiving week: ${weekId}`);

    const results = await Promise.allSettled(
      GAME_MODES.map((modeId) => resetModeLeaderboard(modeId, weekId))
    );

    let successCount = 0;
    let failCount = 0;
    for (let i = 0; i < results.length; i++) {
      const result = results[i];
      if (result.status === "fulfilled") {
        successCount++;
        functions.logger.info(`Reset leaderboard for mode: ${GAME_MODES[i]}`);
      } else {
        failCount++;
        functions.logger.error(
          `Failed to reset leaderboard for mode: ${GAME_MODES[i]}`,
          result.reason
        );
      }
    }

    functions.logger.info(
      `Weekly leaderboard reset complete. Success: ${successCount}, Failed: ${failCount}`
    );
  });
