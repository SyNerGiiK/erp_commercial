RÈGLES TECHNIQUES & SNIPPETS VALIDÉS (ERP ARTISAN)

Ce document contient les implémentations exactes qui fonctionnent sur ce projet. Ne jamais en dévier.

1. GÉNÉRATION PDF (Package 'pdf' & 'printing')

IMPERATIF : Utiliser l'alias as pw pour les widgets PDF.

Imports corrects :

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw; // ALIAS OBLIGATOIRE
import 'package:printing/printing.dart';


Syntaxe Widget :

Utiliser pw.TextStyle, pw.Row, pw.Container, pw.Column.

Exemple : pw.Text("Bonjour", style: pw.TextStyle(fontSize: 20)).

Couleurs & Const :

NE JAMAIS mettre le mot-clé const devant un pw.TextStyle qui utilise une couleur personnalisée (comme PdfColor.fromInt(...)). Cela plante la compilation.

Chargement Fonts :

Toujours charger le thème via pw.ThemeData.withFont(...) avant de créer le pw.Document.

2. NAVIGATION (GoRouter)

Pour passer un objet complexe (ex: Devis) vers une route d'édition :

// Navigation (Sender)
context.push('/ajout_devis/123', extra: monObjetDevis);

// Réception (Receiver - router.dart)
final devis = state.extra as Devis?;


3. SUPABASE & DATES

Supabase renvoie des dates en String (Format ISO 8601).

Dans les fromMap : DateTime.parse(map['date_emission']).

Dans les toMap : 'date_emission': dateEmission.toIso8601String().

Important : Les clés étrangères doivent être suffixées par _id (ex: client_id).

4. DECIMAL (Argent & Quantités)

Interdit : double pour les prix.

Division : (prix / quantite).toDecimal(). Le package retourne un Rational, la conversion est obligatoire.

Multiplication : prix * quantite. (Pas de conversion ! Le package retourne déjà un Decimal).

Parsing : Decimal.parse(json['prix'].toString()). Le .toString() est vital pour éviter les crashs si le JSON envoie un int ou un double.

5. UI & FORMULAIRES

DropdownButtonFormField :

Ne jamais utiliser value si la valeur initiale peut ne pas être dans la liste des items.

Pattern validé : key: ValueKey(maValeur) et initialValue: maValeur.

Validation : Toujours utiliser if (_formKey.currentState!.validate()) avant de sauvegarder.

6. STATE MANAGEMENT (Provider)

Dans l'UI (build) : context.watch<MonViewModel>() ou Consumer<MonViewModel>.

Dans les Actions (onTap) : Provider.of<MonViewModel>(context, listen: false).maFonction().