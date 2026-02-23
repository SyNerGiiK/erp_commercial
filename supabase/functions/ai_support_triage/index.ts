import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "npm:@supabase/supabase-js@2";

const GEMINI_API_KEY = Deno.env.get("GEMINI_API_KEY") || "";
const SUPABASE_URL = Deno.env.get("SUPABASE_URL") || "";
const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") || "";

const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY);

const SYSTEM_PROMPT = `Tu es l'assistant de support IA de CraftOS (SaaS de gestion pour les artisans du BTP).
L'artisan te pose une question (via un ticket SAV). 
Ton but est de lui apporter une réponse précise, utile et polie basée sur ton savoir concernant le logiciel (Devis, Factures, Acomptes, Avoirs, Progress Billing, OCR, etc.).
Si tu penses que la demande est un bug complexe ou requiert une intervention humaine (ex: "mon compte est bloqué", "j'ai été prélevé deux fois"), réponds EXACTEMENT par la chaîne "ESCALATE_TO_HUMAN".
Sinon, donne la marche à suivre claire pour résoudre son problème.`;

Deno.serve(async (req) => {
    try {
        const payload = await req.json();

        // Check if it's a webhook payload from Supabase
        const record = payload.record;
        if (!record || !record.id || !record.description) {
            return new Response("Invalid payload", { status: 400 });
        }

        const ticketId = record.id;
        const userQuery = `Sujet: ${record.subject}\nDescription: ${record.description}`;

        // Call Gemini API
        const geminiResponse = await fetch(`https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=${GEMINI_API_KEY}`, {
            method: "POST",
            headers: {
                "Content-Type": "application/json",
            },
            body: JSON.stringify({
                contents: [{
                    parts: [{ text: userQuery }]
                }],
                systemInstruction: {
                    parts: [{ text: SYSTEM_PROMPT }]
                },
                generationConfig: {
                    temperature: 0.1
                }
            })
        });

        const geminiData = await geminiResponse.json();
        const answer = geminiData.candidates?.[0]?.content?.parts?.[0]?.text;

        if (!answer) {
            throw new Error("Invalid response from Gemini");
        }

        if (answer.trim() === "ESCALATE_TO_HUMAN") {
            // Leave ticket open for God Mode
            console.log(`Ticket ${ticketId} escalated to human.`);
            return new Response(JSON.stringify({ status: "escalated" }), {
                headers: { "Content-Type": "application/json" }
            });
        }

        // Auto-resolve ticket
        const { error } = await supabase
            .from('support_tickets')
            .update({
                status: 'resolved',
                ai_resolution: answer
            })
            .eq('id', ticketId);

        if (error) throw error;

        console.log(`Ticket ${ticketId} auto-resolved by AI.`);
        return new Response(JSON.stringify({ status: "resolved" }), {
            headers: { "Content-Type": "application/json" }
        });

    } catch (error) {
        console.error("Error in ai_support_triage:", error);
        return new Response(JSON.stringify({ error: error.message }), {
            status: 500,
            headers: { "Content-Type": "application/json" }
        });
    }
});
