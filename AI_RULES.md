🧠 AI CONTEXT & RULES - ERP ARTISAN

Ce fichier définit la vérité absolue pour toute génération de code sur ce projet.
L'IA DOIT lire ce fichier avant de répondre à toute demande technique.

1. IDENTITÉ & RÔLE

Projet : ERP pour Artisans (Micro-entreprise).

Stack : Flutter Web (Stable) + Supabase + Provider.

Philosophie : "Zéro dette technique". On préfère un code verbeux et solide à un code court et magique.

2. RÈGLES CRITIQUES (NON NÉGOCIABLES)

💰 Gestion Monétaire (Package decimal)

INTERDIT : Utiliser double pour les montants.

OBLIGATOIRE : Utiliser Decimal.

Division : (a / b).toDecimal() (Conversion Rational -> Decimal obligatoire).

Multiplication : a * b (Retourne déjà un Decimal, pas de conversion).

Affichage : montant.toDouble().toStringAsFixed(2).

🛡️ Sécurité Asynchrone

Règle d'Or : Après CHAQUE await, si on doit utiliser le context (Navigation, SnackBar, Provider), on doit insérer :

await futureFunction();
if (!context.mounted) return; // OU if (!mounted) return; dans un State
Navigator.pop(context);


🗄️ Supabase & Base de Données

Tables : Toujours au PLURIEL (clients, factures).

Foreign Keys : Toujours au SINGULIER + _id (client_id).

RLS Update : Lors d'un update(), toujours retirer le champ user_id de la map, sinon Supabase bloque la requête par sécurité.

🧩 Architecture MVVM (Provider)

Logique : Jamais de logique métier dans l'UI (Views). Tout va dans les ViewModels.

Appels :

Dans build() : context.watch<MonViewModel>() ou Consumer.

Dans les fonctions/callbacks : Provider.of<MonViewModel>(context, listen: false).

🌐 Spécificités Web

Fichiers : Ne JAMAIS utiliser dart:io (File). Utiliser Uint8List (bytes) et image_picker.

PDF : Utiliser le package printing et pdf.

Import OBLIGATOIRE : import 'package:pdf/widgets.dart' as pw;.

Ne jamais mettre const devant un pw.TextStyle avec une couleur custom.

3. ARBORESCENCE & STANDARDS

lib/config/ : Routes (GoRouter), Thème, SupabaseConfig.

lib/models/ : Classes de données (avec fromMap, toMap, copyWith).

lib/viewmodels/ : Gestion d'état (ChangeNotifier).

lib/views/ : Écrans (Scaffold).

lib/widgets/ : Composants réutilisables.

4. SNIPPETS VALIDÉS (A COPIER)

DropdownButtonFormField :
Ne pas utiliser value. Utiliser key + initialValue.

DropdownButtonFormField<String>(
  key: ValueKey(currentValue), // Vital pour le refresh
  initialValue: currentValue,
  items: ...,
  onChanged: ...
)


Formatage Date (FR) :

DateFormat('dd/MM/yyyy', 'fr_FR').format(date)
