import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

const db = admin.firestore();

export const autoDeleteExpiredJobs = functions.pubsub
    .schedule("every 24 hours")
    .onRun(async (context) => {
        const now = admin.firestore.Timestamp.now();
        const expiredJobsQuery = db.collection("jobs")
            .where("expiresAt", "<=", now)
            .limit(500); // Batch limit

        // Recursive delete helper
        async function deleteQueryBatch(query: admin.firestore.Query, size: number) {
            const snapshot = await query.get();
            if (snapshot.size === 0) {
                return 0;
            }

            const batch = db.batch();
            for (const doc of snapshot.docs) {
                // Delete subcollections (applications) manually or use logic
                // For simplicity and standard constraints, we'll delete applications subcollection first
                // Warning: This simplistic approach might hit limits if applications are huge. 
                // A robust system uses a recursive delete tool, but we will do a basic subcollection fetch here.
                const applicationsSnapshot = await doc.ref.collection("applications").get();
                applicationsSnapshot.forEach(appDoc => {
                    batch.delete(appDoc.ref);
                });

                batch.delete(doc.ref);
            }

            await batch.commit();
            return snapshot.size;
        }

        let totalDeleted = 0;
        // eslint-disable-next-line no-constant-condition
        while (true) {
            const deletedCount = await deleteQueryBatch(expiredJobsQuery, 500);
            totalDeleted += deletedCount;
            if (deletedCount === 0) {
                break;
            }
        }

        console.log(`Deleted ${totalDeleted} expired jobs.`);
        return null;
    });
