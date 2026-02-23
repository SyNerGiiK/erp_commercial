import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "npm:@supabase/supabase-js@2";

const GEMINI_API_KEY = Deno.env.get("GEMINI_API_KEY") || "AIzaSyB05E7l8l6CKHLGzJVFzPwkkk1T_R9euYY";
const SUPABASE_URL = Deno.env.get("SUPABASE_URL") || "";
const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") || "";

const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY);

const SYSTEM_PROMPT = `Tu es l'assistant de support IA officiel de CraftOS (SaaS PWA de gestion ultime pour les artisans du BTP - ex-ERP Artisan 3.0).
L'artisan te pose une question (via un ticket SAV). Ton but est de lui apporter une réponse ultra-précise, utile et polie basée sur ton encyclopédie du logiciel.

### ENCYCLOPÉDIE CRAFTOS ###
- Architecture: Flutter Web hébergé sur Vercel. Supabase en backend.
- Devis & Factures: L'artisan peut créer des devis, générer des factures d'acompte (%) ou de solde.
- Progress Billing: Possibilité de facturer à l'avancement (situations de travaux) via des arborescences de tâches complexes.
- OCR (God Eye) : Accessible via un bouton flottant avec une icône Magie (étincelles). Permet de scanner des devis fournisseurs pour les importer automatiquement.
- Module IA (Aïtise ton devis) : Un bouton violet avec des étoiles dans le Devis. L'IA Gemini 2.5 Flash corrige l'orthographe, optimise les descriptions commerciales et structure le document pour qu'il soit plus vendeur.
- Dashboard / Rentabilité: Analyse des marges réelles, marges théoriques, heures pointées et facturation totale.
- Support Center & God Mode: Le menu de gauche (ruban latéral Aurora 2030) contient l'accès au 'Centre d'aide I.A.' en bas. Pour les administrateurs, il y a un 'God Mode' (Menu Super-Cockpit) pour gérer globalement la BDD.
- Monnaie: La devise principale gérée est l'Euro, avec un typage strict en Decimal pour éviter les bugs financiers.
- Exports: Tous les documents (Devis, Factures) sont générés en PDF via un moteur natif Flutter (pw.Document).
- Récurrence : Gestion des factures récurrentes pour les contrats de maintenance.

### RÈGLES DE RÉPONSE ###
1. Si l'artisan cherche un bouton (ex: "Où est l'OCR ?", "Comment améliorer mon devis ?"), explique-lui précisément OÙ cliquer en te basant sur l'encyclopédie.
2. Sois chaleureux, concis et formates tes réponses pour qu'elles soient lisibles.
3. Si la demande est une suppression de compte ("je veux me désabonner"), un bug critique système bloquant l'app, ou un problème lié à l'argent (prélèvement en double) : réponds UNIQUEMENT par la chaîne exacte "ESCALATE_TO_HUMAN". Cette chaîne bloquera l'IA et mettra le ticket en mode Humain.
Sinon, résous son problème toi-même en te basant sur CraftOS.`;

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
        const geminiResponse = await fetch(`https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=${GEMINI_API_KEY}`, {
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

        if (geminiData.error) {
            throw new Error(`Gemini API Error: ${geminiData.error.message || JSON.stringify(geminiData.error)}`);
        }

        const answer = geminiData.candidates?.[0]?.content?.parts?.[0]?.text;

        if (!answer) {
            throw new Error(`Invalid response from Gemini: ${JSON.stringify(geminiData)}`);
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
        return new Response(JSON.stringify({ error: (error as Error).message }), {
            status: 500,
            headers: { "Content-Type": "application/json" }
        });
    }
});
