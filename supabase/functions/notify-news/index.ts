import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from "https://esm.sh/@supabase/supabase-client@2"
import { JWT } from "https://esm.sh/google-auth-library@9"

/**
 * Supabase Edge Function: notify-news
 * 
 * This function is triggered (usually by a Database Webhook) when a new news record is inserted.
 * It fetches all FCM tokens from the 'profiles' table and sends a notification via Firebase Cloud Messaging (V1).
 */

const SUPABASE_URL = Deno.env.get("SUPABASE_URL") ?? ""
const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? ""

const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY)

serve(async (req) => {
    try {
        const payload = await req.json()
        console.log("FCM Notification Triggered for payload:", JSON.stringify(payload))

        // 1. Get Access Token using Service Account (Firebase Admin Flow)
        const { accessToken, projectID } = await getFirebaseCredentials()

        if (!projectID) {
            throw new Error("Missing FIREBASE_PROJECT_ID from service account credentials")
        }

        // 2. Send to topic 'all_users' instead of individual tokens
        const message = {
            message: {
                topic: "all_users",  // 🚀 Topic-based delivery
                notification: {
                    title: "إتقان أكاديمي - خبر جديد",
                    body: payload.record?.title || "تفقد التطبيق لرؤية آخر الأخبار",
                    image: payload.record?.image_url || "",  // 🚀 Image support
                },
                data: {
                    route: "home", // Target route in Flutter app
                    id: payload.record?.id?.toString() || "",
                },
                android: {
                    priority: "high",
                    notification: {
                        channel_id: "high_importance_channel",
                        sound: "default",
                        click_action: "FLUTTER_NOTIFICATION_CLICK",  // 🚀 Click action
                    },
                },
                apns: {
                    payload: {
                        aps: {
                            sound: "default",
                        },
                    },
                },
            },
        }

        console.log("Sending notification to topic: all_users")

        const res = await fetch(
            `https://fcm.googleapis.com/v1/projects/${projectID}/messages:send`,
            {
                method: "POST",
                headers: {
                    "Content-Type": "application/json",
                    Authorization: `Bearer ${accessToken}`,
                },
                body: JSON.stringify(message),
            }
        )

        const resData = await res.json()

        if (!res.ok) {
            console.error("Failed to send notification:", resData)
            throw new Error(`FCM Error: ${JSON.stringify(resData)}`)
        }

        console.log("Notification sent successfully:", resData)

        return new Response(JSON.stringify({
            status: "success",
            message_id: resData.name,
            topic: "all_users"
        }), {
            headers: { "Content-Type": "application/json" },
        })

    } catch (error) {
        console.error("Critical Error in notify-news function:", error.message)
        return new Response(JSON.stringify({ error: error.message }), {
            status: 500,
            headers: { "Content-Type": "application/json" },
        })
    }
})

/**
 * Fetches the Google OAuth2 Access Token and Project ID for FCM v1
 * Uses the FIREBASE_SERVICE_ACCOUNT secret from Supabase environment variables.
 */
async function getFirebaseCredentials() {
    const serviceAccountJson = Deno.env.get("FIREBASE_SERVICE_ACCOUNT")

    if (!serviceAccountJson) {
        throw new Error("Missing FIREBASE_SERVICE_ACCOUNT environment variable")
    }

    let serviceAccount
    try {
        serviceAccount = JSON.parse(serviceAccountJson)
    } catch (e) {
        throw new Error("Failed to parse FIREBASE_SERVICE_ACCOUNT as JSON")
    }

    const { project_id: projectID, client_email: clientEmail, private_key: privateKey } = serviceAccount

    if (!projectID || !clientEmail || !privateKey) {
        throw new Error("Missing required fields in FIREBASE_SERVICE_ACCOUNT (project_id, client_email, or private_key)")
    }

    // 🚀 CRITICAL FIX: Replace literal \n with actual newline characters
    const formattedPrivateKey = privateKey.replace(/\\n/g, "\n")

    const client = new JWT({
        email: clientEmail,
        key: formattedPrivateKey,
        scopes: ["https://www.googleapis.com/auth/cloud-platform"],
    })

    const tokens = await client.authorize()
    return {
        accessToken: tokens.access_token,
        projectID: projectID
    }
}
