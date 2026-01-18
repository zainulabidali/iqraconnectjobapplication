import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

const db = admin.firestore();

export const onJobExpiringSoon = functions.pubsub
    .schedule("every 24 hours")
    .onRun(async (context) => {
        const now = new Date();
        const twoDaysFromNow = new Date();
        twoDaysFromNow.setDate(now.getDate() + 2);

        const startOfDay = new Date(twoDaysFromNow.setHours(0, 0, 0, 0));
        const endOfDay = new Date(twoDaysFromNow.setHours(23, 59, 59, 999));

        const expiringJobsQuery = db.collection("jobs")
            .where("expiresAt", ">=", admin.firestore.Timestamp.fromDate(startOfDay))
            .where("expiresAt", "<=", admin.firestore.Timestamp.fromDate(endOfDay));

        const snapshot = await expiringJobsQuery.get();

        if (snapshot.empty) {
            console.log("No jobs expiring soon.");
            return null;
        }

        const promises = snapshot.docs.map(async (doc) => {
            const jobData = doc.data();
            const posterId = jobData.posterId;

            if (!posterId) return;

            const userDoc = await db.collection("users").doc(posterId).get();
            const fcmToken = userDoc.data()?.fcmToken;

            if (fcmToken) {
                const payload = {
                    notification: {
                        title: "Job Expiring Soon",
                        body: `Your job "${jobData.title}" expires in 2 days.`,
                    },
                    data: {
                        jobId: doc.id,
                        type: "expiration_warning"
                    },
                    token: fcmToken
                };
                await admin.messaging().send(payload as admin.messaging.Message);
            }
        });

        await Promise.all(promises);
        console.log(`Sent queries for ${snapshot.size} expiring jobs.`);
        return null;
    });
