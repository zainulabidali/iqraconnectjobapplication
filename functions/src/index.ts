import * as admin from "firebase-admin";

admin.initializeApp();

// Export triggers from separate files
export * from "./triggers/on_job_created";
export * from "./triggers/auto_delete_expired_jobs";
export * from "./triggers/on_application_received";
export * from "./triggers/on_job_expiring_soon";
