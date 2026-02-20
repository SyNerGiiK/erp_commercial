---
trigger: always_on
---

ERP Artisan — Instructions IA (System Rules)

Rôle : Expert Flutter Web & Supabase. Toujours répondre en FRANÇAIS.

Projet : SaaS de gestion BTP/Artisans (Devis, Factures, Récurrence, Temps, Rappels, Progress Billing).

1. ARCHITECTURE STRICTE (MVVM)

Flux : Views → ViewModels (Provider) → Repositories (Interface+Impl) → Supabase.

ViewModels : Héritent de BaseViewModel (_loadingDepth réentrant). Toute opération passe par executeOperation().

Repositories : Héritent de BaseRepository. Interfaces IXxxRepository injectées par constructeur optionnel.

Services : Classes statiques pures (Tva, Relance, Archivage, Pdf, Export, Echeance).

2. ☢️ RÈGLES CRITIQUES (ZÉRO TOLÉRANCE)

ARGENT = Decimal : INTERDICTION d'utiliser double.

Division : (total / qte).toDecimal() (OBLIGATOIRE).

Multiplication : prix * qte (INTERDIT d'utiliser .toDecimal()).

Formatage : montant.toDouble().toStringAsFixed(2).

SÉCURITÉ ASYNC (mounted) : Après CHAQUE await dans l'UI, insérer if (!mounted) return; (State) ou if (!context.mounted) return; avant d'utiliser le context.

FLUTTER 3.32+ UI :

DropdownButtonFormField : Utiliser initialValue + key: ValueKey(val). JAMAIS value:.

Colors : Utiliser .withValues(alpha: X). JAMAIS .withOpacity().

RadioListTile : Utiliser RadioGroup<T>. Pas de groupValue/onChanged directs.

Switch : activeTrackColor, pas activeColor.

ListTile : leading/trailing, JAMAIS secondary.

PDF : Toujours import 'package:pdf/widgets.dart' as pw;. Pas de const avec PdfColor.fromInt().

STATE MANAGEMENT : Dans initState ou les callbacks (onTap), utiliser listen: false (ex: context.read<VM>()).

3. BASE DE DONNÉES (SUPABASE PostgreSQL)

Nommage : Tables au PLURIEL (clients, factures). Foreign Keys au SINGULIER + _id (client_id).

Types : UUID (PK), TIMESTAMPTZ (dates), NUMERIC (montants).

CRUD (BaseRepository) : * prepareForInsert : ajoute user_id (Auth), retire id.

prepareForUpdate : retire user_id (RLS) et id. OBLIGATOIRE sinon RLS bloque.

Triggers SQL Actifs :

trg_audit_* : Log automatique dans audit_logs (INSERT/UPDATE/DELETE).

trg_protect_validated_facture : Bloque modif financière si facture validée.

trg_*_updated_at : Auto-update des dates.

4. DESIGN SYSTEM (AURORA 2030)

Thème : AppTheme (lib/config/theme.dart). Glassmorphism, ombres colorées (Indigo→Violet).

Typographie : GoogleFonts.spaceGrotesk() (Titres) / inter() (Corps).

Composants : GlassContainer, AuroraBackground.

Couleurs/Ombres : Utiliser AppTheme.surfaceGlass* et AppTheme.shadow*. JAMAIS Colors.black pour les ombres.

5. MODÈLES & GESTION MÉTIER

Factures / Devis : Avoirs en positifs. Champs récents : devise, tauxChange, notesPrivees.

Progress Billing : Arbre Devis → LigneDevis → LigneChiffrage. Suivi estAchete et avancementMo.

Factures Récurrentes : Enum FrequenceRecurrence.

TempsActivite : Calcul CA potentiel, liaison client/projet.

Rappels : 7 types (URSSAF, CFE, TVA, etc.), générés par EcheanceService.

6. TESTS & QUALITÉ

662 Tests Actifs : 100% de réussite exigée.

Zéro Régression : Chaque modification métier implique la mise à jour des tests mocktail associés.