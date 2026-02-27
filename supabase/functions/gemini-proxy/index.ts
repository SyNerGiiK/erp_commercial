import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "npm:@supabase/supabase-js@2";

const GEMINI_API_KEY = Deno.env.get("GEMINI_API_KEY") || "";
const SUPABASE_URL = Deno.env.get("SUPABASE_URL") || "";
const SUPABASE_ANON_KEY = Deno.env.get("SUPABASE_ANON_KEY") || "";

const GEMINI_URL =
  `https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=${GEMINI_API_KEY}`;

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
};

// ──────────────────────────────────────────────
//  Validation JWT — vérifie que l'appelant est
//  un utilisateur Supabase authentifié.
// ──────────────────────────────────────────────
async function getAuthenticatedUser(req: Request) {
  const authHeader = req.headers.get("Authorization");
  if (!authHeader) return null;

  const supabase = createClient(SUPABASE_URL, SUPABASE_ANON_KEY, {
    global: { headers: { Authorization: authHeader } },
  });

  const { data: { user }, error } = await supabase.auth.getUser();
  if (error || !user) return null;
  return user;
}

// ──────────────────────────────────────────────
//  Appel Gemini mutualisé
// ──────────────────────────────────────────────
async function callGemini(body: unknown): Promise<unknown> {
  if (!GEMINI_API_KEY) {
    throw new Error("GEMINI_API_KEY non configurée côté serveur.");
  }

  const response = await fetch(GEMINI_URL, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify(body),
  });

  if (!response.ok) {
    const err = await response.text();
    throw new Error(`Gemini API error ${response.status}: ${err}`);
  }

  return await response.json();
}

// ──────────────────────────────────────────────
//  Action : OCR ticket de caisse
// ──────────────────────────────────────────────
async function extractReceipt(base64Image: string): Promise<unknown> {
  const data = await callGemini({
    contents: [
      {
        parts: [
          {
            text:
              "Tu es un extracteur de tickets de caisse. Renvoie STRICTEMENT un JSON valide avec les clés 'merchant_name' (String), 'total_amount' (Number), 'tax_amount' (Number) et 'date' (YYYY-MM-DD). N'inclus aucun backtick ou mot supplémentaire.",
          },
          {
            inlineData: { mimeType: "image/jpeg", data: base64Image },
          },
        ],
      },
    ],
    generationConfig: {
      temperature: 0.1,
      responseMimeType: "application/json",
    },
  });

  const text =
    (data as any)?.candidates?.[0]?.content?.parts?.[0]?.text ?? null;
  if (!text) throw new Error("Réponse Gemini vide pour extractReceipt.");
  return JSON.parse(text);
}

// ──────────────────────────────────────────────
//  Action : Génération structure devis (RAG)
// ──────────────────────────────────────────────
async function generateQuoteStructure(
  userDictation: string,
  catalogJSON: string,
): Promise<unknown> {
  const data = await callGemini({
    contents: [
      {
        parts: [
          {
            text:
              `Tu es un Économiste de la construction. L'utilisateur dicte des travaux: '${userDictation}'.\nCatalogue: ${catalogJSON}\nTu dois structurer le devis. Règle 1: Organise par sections (cree des lignes 'titre'). Règle 2: Ajoute le matériel ('vente') et la main d'œuvre ('service'). Règle 3: Utilise le catalogue fourni. Règle 4: Si non trouvé, estime le prix au marché et mets 'is_ai_estimated': true. Renvoie STRICTEMENT un tableau JSON avec 'type_ligne' ('titre', 'article'), 'designation', 'type_activite' ('vente', 'service'), 'quantite', 'prix_unitaire', 'is_ai_estimated', 'ordre'.`,
          },
        ],
      },
    ],
    generationConfig: {
      temperature: 0.2,
      responseMimeType: "application/json",
    },
  });

  const text =
    (data as any)?.candidates?.[0]?.content?.parts?.[0]?.text ?? null;
  if (!text) throw new Error("Réponse Gemini vide pour generateQuoteStructure.");
  return JSON.parse(text);
}

// ──────────────────────────────────────────────
//  Handler principal
// ──────────────────────────────────────────────
Deno.serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    // Authentification obligatoire
    const user = await getAuthenticatedUser(req);
    if (!user) {
      return new Response(
        JSON.stringify({ error: "Non authentifié." }),
        { status: 401, headers: { ...corsHeaders, "Content-Type": "application/json" } },
      );
    }

    const { action, payload } = await req.json();

    let result: unknown;

    switch (action) {
      case "extractReceipt": {
        const { base64Image } = payload as { base64Image: string };
        if (!base64Image) throw new Error("Champ 'base64Image' manquant.");
        result = await extractReceipt(base64Image);
        break;
      }

      case "generateQuoteStructure": {
        const { userDictation, catalogJSON } = payload as {
          userDictation: string;
          catalogJSON: string;
        };
        if (!userDictation || !catalogJSON) {
          throw new Error("Champs 'userDictation' et 'catalogJSON' requis.");
        }
        result = await generateQuoteStructure(userDictation, catalogJSON);
        break;
      }

      default:
        return new Response(
          JSON.stringify({ error: `Action inconnue : '${action}'.` }),
          { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } },
        );
    }

    return new Response(
      JSON.stringify({ success: true, data: result }),
      { status: 200, headers: { ...corsHeaders, "Content-Type": "application/json" } },
    );
  } catch (e) {
    const message = e instanceof Error ? e.message : String(e);
    return new Response(
      JSON.stringify({ success: false, error: message }),
      { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } },
    );
  }
});
