// @ts-nocheck
// Edge Function Blueprint — Supabase Edge Function pour envoi d'emails transactionnels
// Déployer via : supabase functions deploy send-email
//
// Variables d'environnement requises (Supabase Vault) :
//   RESEND_API_KEY    — Clé API Resend (https://resend.com)
//   FROM_EMAIL        — Adresse expéditrice vérifiée (ex: factures@mondomaine.fr)
//
// Endpoint : POST /functions/v1/send-email
// Headers  : Authorization: Bearer <supabase_anon_key>
//            Content-Type: application/json
//
// Body :
// {
//   "to": "client@email.com",
//   "subject": "Facture FA-2026-001",
//   "body": "Bonjour, veuillez trouver...",
//   "pdfBase64": "<base64_encoded_pdf>",       // optionnel
//   "pdfFilename": "FA-2026-001.pdf",          // requis si pdfBase64 fourni
//   "documentType": "facture|devis|relance",
//   "documentId": "uuid",                       // pour audit trail
//   "documentNumero": "FA-2026-001"             // pour audit trail
// }
//
// Response 200 : { "success": true, "messageId": "..." }
// Response 4xx : { "success": false, "error": "..." }

import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const RESEND_API_URL = "https://api.resend.com/emails";

interface EmailRequest {
  to: string;
  subject: string;
  body: string;
  pdfBase64?: string;
  pdfFilename?: string;
  documentType?: string;
  documentId?: string;
  documentNumero?: string;
}

serve(async (req: Request) => {
  // CORS preflight
  if (req.method === "OPTIONS") {
    return new Response(null, {
      headers: {
        "Access-Control-Allow-Origin": "*",
        "Access-Control-Allow-Methods": "POST, OPTIONS",
        "Access-Control-Allow-Headers":
          "authorization, x-client-info, apikey, content-type",
      },
    });
  }

  if (req.method !== "POST") {
    return new Response(JSON.stringify({ success: false, error: "Method not allowed" }), {
      status: 405,
      headers: { "Content-Type": "application/json" },
    });
  }

  try {
    // Vérifier l'authentification via JWT Supabase
    const authHeader = req.headers.get("Authorization");
    if (!authHeader) {
      return new Response(
        JSON.stringify({ success: false, error: "Missing authorization header" }),
        { status: 401, headers: { "Content-Type": "application/json" } }
      );
    }

    const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
    const supabaseServiceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
    const resendApiKey = Deno.env.get("RESEND_API_KEY");
    const fromEmail = Deno.env.get("FROM_EMAIL") || "noreply@erp-artisan.fr";

    if (!resendApiKey) {
      return new Response(
        JSON.stringify({ success: false, error: "RESEND_API_KEY not configured" }),
        { status: 500, headers: { "Content-Type": "application/json" } }
      );
    }

    // Valider le JWT et extraire le user_id
    const supabase = createClient(supabaseUrl, supabaseServiceKey);
    const token = authHeader.replace("Bearer ", "");
    const { data: { user }, error: authError } = await supabase.auth.getUser(token);

    if (authError || !user) {
      return new Response(
        JSON.stringify({ success: false, error: "Invalid token" }),
        { status: 401, headers: { "Content-Type": "application/json" } }
      );
    }

    // Parser et valider le body
    const body: EmailRequest = await req.json();

    if (!body.to || !body.subject || !body.body) {
      return new Response(
        JSON.stringify({ success: false, error: "Missing required fields: to, subject, body" }),
        { status: 400, headers: { "Content-Type": "application/json" } }
      );
    }

    // Construire la requête Resend
    const resendPayload: Record<string, unknown> = {
      from: fromEmail,
      to: [body.to],
      subject: body.subject,
      text: body.body,
    };

    // Pièce jointe PDF si fournie
    if (body.pdfBase64 && body.pdfFilename) {
      resendPayload.attachments = [
        {
          filename: body.pdfFilename,
          content: body.pdfBase64,
          // Resend attend du base64 directement
        },
      ];
    }

    // Envoi via Resend API
    const resendResponse = await fetch(RESEND_API_URL, {
      method: "POST",
      headers: {
        "Authorization": `Bearer ${resendApiKey}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify(resendPayload),
    });

    const resendResult = await resendResponse.json();

    if (!resendResponse.ok) {
      console.error("Resend error:", resendResult);
      return new Response(
        JSON.stringify({
          success: false,
          error: resendResult.message || "Email sending failed",
        }),
        { status: resendResponse.status, headers: { "Content-Type": "application/json" } }
      );
    }

    // Log audit dans Supabase (fire-and-forget, ne bloque pas la réponse)
    if (body.documentType && body.documentId) {
      const tableName = body.documentType === "relance" ? "factures" : `${body.documentType}s`;
      const action = body.documentType === "relance" ? "RELANCE_SENT" : "EMAIL_SENT";

      supabase
        .from("audit_logs")
        .insert({
          user_id: user.id,
          table_name: tableName,
          record_id: body.documentId,
          action: action,
          new_data: {
            destinataire: body.to,
            numero_document: body.documentNumero || null,
            sujet: body.subject,
            resend_message_id: resendResult.id,
            sent_via: "edge_function",
          },
        })
        .then(() => {})
        .catch((err: Error) => console.error("Audit log error:", err));
    }

    return new Response(
      JSON.stringify({
        success: true,
        messageId: resendResult.id,
      }),
      {
        status: 200,
        headers: {
          "Content-Type": "application/json",
          "Access-Control-Allow-Origin": "*",
        },
      }
    );
  } catch (error) {
    console.error("Edge function error:", error);
    return new Response(
      JSON.stringify({ success: false, error: "Internal server error" }),
      { status: 500, headers: { "Content-Type": "application/json" } }
    );
  }
});
