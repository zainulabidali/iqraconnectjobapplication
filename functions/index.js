const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();

exports.sendJobNotification = functions.firestore
  .document("jobs/{jobId}")
  .onCreate(async (snapshot, context) => {
    try {
      const job = snapshot.data();
      const jobId = context.params.jobId;

      // 🔹 Strictly match Flutter JobModel fields
      const title = job.title || "New Job Posted";
      // company is required in JobModel but safe fallback here
      const company = job.company || "";
      const state = job.state || "";
      const district = job.district || "";
      const jobType = job.jobType || "";

      // Format location: "District, State" or fallback
      let location = "";
      if (district && state) {
        location = `${district}, ${state}`;
      } else {
        location = district || state || "Location N/A";
      }

      // 🔹 1. Save notification for in-app history
      // MUST include: title, jobId, jobType, state, district, createdAt
      await admin.firestore().collection("notifications").add({
        title: title,
        jobId: jobId,
        jobType: jobType,
        state: state,
        district: district,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
        // Optional but helpful fields
        company: company,
        body: `${location} • ${jobType}`,
        type: "new_job",
      });

      // 🔹 2. Send FCM push notification to 'all_users'
      // Body must show: location (district + state) + job type
      const notificationBody = `${location} • ${jobType}`;

      await admin.messaging().send({
        topic: "all_users",
        notification: {
          title: title,
          body: notificationBody,
        },
        data: {
          jobId: jobId,
          screen: "job_detail",
          click_action: "FLUTTER_NOTIFICATION_CLICK",
        },
      });

      console.log(`Job notification sent for ${jobId} to all_users`);
    } catch (error) {
      console.error("Error sending job notification:", error);
    }
  });
