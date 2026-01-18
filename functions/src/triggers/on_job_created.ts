import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

export const onJobCreated = functions.firestore
    .document("jobs/{jobId}")
    .onCreate(async (snapshot, context) => {
        const jobData = snapshot.data();
        const jobId = context.params.jobId;

        if (!jobData) return null;

        const payload = {
            notification: {
                title: "New Job Posted",
                body: `${jobData.title} – ${jobData.district}`,
            },
            data: {
                jobId: jobId,
                click_action: "FLUTTER_NOTIFICATION_CLICK",
            },
            android: {
                priority: "high", // Forces immediate wake on Android
            },
            apns: {
                payload: {
                    aps: {
                        contentAvailable: true, // Optimizes delivery for iOS
                    },
                },
            },
            topic: "new_jobs",
        };

        try {
            const response = await admin.messaging().send(payload as admin.messaging.Message);
            console.log("Successfully sent message:", response);
            return response;
        } catch (error) {
            console.log("Error sending message:", error);
            return null;
        }
    });
