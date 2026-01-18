import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

const db = admin.firestore();

export const onApplicationReceived = functions.firestore
    .document("jobs/{jobId}/applications/{applicationId}")
    .onCreate(async (snapshot, context) => {
        const applicationId = context.params.applicationId;
        const jobId = context.params.jobId;
        const applicationData = snapshot.data();

        if (!applicationData) return null;

        try {
            // 1. Get Job Details to find the Poster
            const jobDoc = await db.collection("jobs").doc(jobId).get();
            if (!jobDoc.exists) return null;
            const jobData = jobDoc.data();
            const posterId = jobData?.posterId;

            if (!posterId) return null;

            // 2. Get Poster's FCM Token
            // Assuming we store FCM tokens in users/{userId} -> fcmToken (string or array)
            const userDoc = await db.collection("users").doc(posterId).get();
            if (!userDoc.exists) return null;

            const userData = userDoc.data();
            const fcmToken = userData?.fcmToken; // Or array of tokens

            if (!fcmToken) {
                console.log(`No FCM token found for user ${posterId}`);
                return null;
            }

            // 3. Send Notification
            const payload = {
                notification: {
                    title: "New Job Application",
                    body: `Someone applied for ${jobData?.title}`,
                },
                data: {
                    jobId: jobId,
                    applicationId: applicationId,
                    click_action: "FLUTTER_NOTIFICATION_CLICK",
                    type: "application"
                },
                token: fcmToken
            };

            await admin.messaging().send(payload as admin.messaging.Message);
            console.log(`Notification sent to poster ${posterId}`);
        } catch (error) {
            console.error("Error sending application notification:", error);
        }
        return null;
    });
