import 'package:decimal/decimal.dart';
import '../models/urssaf_model.dart';
import '../models/facture_model.dart';

/// Statut TVA d'un micro-entrepreneur selon Art. 293 B CGI.
///
/// Règles 2026 :
/// - CA < seuil de base → franchise en base (pas de TVA)
/// - CA entre seuil de base et seuil majoré → franchise maintenue l'année en cours,
///   assujettissement dès le 1er janvier N+1 si dépassement confirmé
/// - CA > seuil majoré → assujettissement immédiat dès le jour du dépassement
enum StatutTva {
  /// Franchise en base — TVA non applicable (Art. 293 B CGI)
  enFranchise,

  /// CA approche 80 % du seuil de base — alerte préventive
  approcheSeuil,

  /// Seuil de base dépassé — assujettissement au 1er janvier N+1
  seuilBaseDepasse,

  /// Seuil majoré dépassé — assujettissement IMMÉDIAT
  seuilMajoreDepasse,
}

/// Résultat de l'analyse TVA pour un type d'activité.
class AnalyseTva {
  final StatutTva statut;
  final Decimal caActuel;
  final Decimal seuilBase;
  final Decimal seuilMajore;
  final String typeActivite; // 'vente' ou 'service'

  AnalyseTva({
    required this.statut,
    required this.caActuel,
    required this.seuilBase,
    required this.seuilMajore,
    required this.typeActivite,
  });

  /// Progression vers le seuil de base (0.0 → 1.0+)
  double get progressionBase =>
      seuilBase > Decimal.zero ? caActuel.toDouble() / seuilBase.toDouble() : 0;

  /// Progression vers le seuil majoré (0.0 → 1.0+)
  double get progressionMajore => seuilMajore > Decimal.zero
      ? caActuel.toDouble() / seuilMajore.toDouble()
      : 0;

  /// Marge restante avant seuil de base
  Decimal get margeBase =>
      seuilBase > caActuel ? seuilBase - caActuel : Decimal.zero;

  /// Marge restante avant seuil majoré
  Decimal get margeMajore =>
      seuilMajore > caActuel ? seuilMajore - caActuel : Decimal.zero;

  /// Message résumé lisible
  String get message {
    switch (statut) {
      case StatutTva.enFranchise:
        return 'Franchise TVA — $typeActivite : ${caActuel.toStringAsFixed(0)}€ / ${seuilBase.toStringAsFixed(0)}€';
      case StatutTva.approcheSeuil:
        return '⚠️ Attention $typeActivite : ${caActuel.toStringAsFixed(0)}€ — vous approchez du seuil TVA (${seuilBase.toStringAsFixed(0)}€)';
      case StatutTva.seuilBaseDepasse:
        return '🔶 Seuil de base TVA dépassé ($typeActivite). Assujettissement au 1er janvier N+1.';
      case StatutTva.seuilMajoreDepasse:
        return '🔴 Seuil majoré TVA dépassé ($typeActivite) ! Assujettissement IMMÉDIAT.';
    }
  }

  /// Indique si une alerte doit être affichée
  bool get requiresAlert =>
      statut == StatutTva.approcheSeuil ||
      statut == StatutTva.seuilBaseDepasse ||
      statut == StatutTva.seuilMajoreDepasse;

  /// Indique si la TVA doit être immédiatement appliquée
  bool get forceTvaImmediate => statut == StatutTva.seuilMajoreDepasse;
}

/// Résultat global de l'analyse TVA couvrant vente ET service.
class BilanTva {
  final AnalyseTva vente;
  final AnalyseTva service;

  BilanTva({required this.vente, required this.service});

  /// Le statut le plus critique entre vente et service
  StatutTva get statutGlobal {
    final v = vente.statut.index;
    final s = service.statut.index;
    return v >= s ? vente.statut : service.statut;
  }

  /// Au moins une analyse nécessite une alerte
  bool get requiresAlert => vente.requiresAlert || service.requiresAlert;

  /// Au moins une analyse force l'assujettissement immédiat
  bool get forceTvaImmediate =>
      vente.forceTvaImmediate || service.forceTvaImmediate;

  /// Messages d'alerte combinés
  List<String> get alertMessages => [
        if (vente.requiresAlert) vente.message,
        if (service.requiresAlert) service.message,
      ];
}

/// Service de gestion TVA micro-entreprise selon Art. 293 B CGI.
///
/// Calcule le CA cumulé YTD, compare aux seuils versionnés de [UrssafConfig],
/// et détermine le statut franchise/assujettissement.
class TvaService {
  /// Seuil d'alerte préventive (80 % du seuil de base)
  static const double seuilAlertePct = 0.80;

  /// Analyse TVA pour un type d'activité spécifique.
  static AnalyseTva analyserActivite({
    required Decimal caYtd,
    required Decimal seuilBase,
    required Decimal seuilMajore,
    required String typeActivite,
  }) {
    StatutTva statut;

    if (caYtd >= seuilMajore) {
      statut = StatutTva.seuilMajoreDepasse;
    } else if (caYtd >= seuilBase) {
      statut = StatutTva.seuilBaseDepasse;
    } else if (seuilBase > Decimal.zero &&
        caYtd.toDouble() / seuilBase.toDouble() >= seuilAlertePct) {
      statut = StatutTva.approcheSeuil;
    } else {
      statut = StatutTva.enFranchise;
    }

    return AnalyseTva(
      statut: statut,
      caActuel: caYtd,
      seuilBase: seuilBase,
      seuilMajore: seuilMajore,
      typeActivite: typeActivite,
    );
  }

  /// Analyse TVA complète (vente + service) à partir des seuils de la config.
  static BilanTva analyser({
    required Decimal caVenteYtd,
    required Decimal caServiceYtd,
    required UrssafConfig config,
  }) {
    return BilanTva(
      vente: analyserActivite(
        caYtd: caVenteYtd,
        seuilBase: config.seuilTvaMicroVente,
        seuilMajore: config.seuilTvaMicroVenteMaj,
        typeActivite: 'vente',
      ),
      service: analyserActivite(
        caYtd: caServiceYtd,
        seuilBase: config.seuilTvaMicroService,
        seuilMajore: config.seuilTvaMicroServiceMaj,
        typeActivite: 'service',
      ),
    );
  }

  /// Calcule le CA cumulé YTD (Year-To-Date) ventilé vente/service
  /// à partir d'une liste de factures encaissées.
  ///
  /// La ventilation utilise le `typeActivite` de chaque ligne :
  /// - 'vente', 'marchandise', 'negoce' → caVente
  /// - tout le reste (service, prestation, etc.) → caService
  static ({Decimal caVente, Decimal caService}) calculerCaYtd(
    List<Facture> factures, {
    int? annee,
  }) {
    final year = annee ?? DateTime.now().year;
    Decimal caVente = Decimal.zero;
    Decimal caService = Decimal.zero;

    for (final f in factures) {
      // Seules les factures validées/payées comptent pour le CA
      if (f.statut != 'validee' && f.statut != 'payee') continue;
      if (f.dateEmission.year != year) continue;
      // Les avoirs sont déduits (totalHt négatif dans ce cas)
      if (f.type == 'avoir') {
        // Répartition au prorata si le type d'avoir n'est pas détaillé
        caService -= f.totalHt;
        continue;
      }

      // Ventilation par lignes si disponibles
      if (f.lignes.isNotEmpty) {
        for (final l in f.lignes) {
          if (_isVente(l.typeActivite)) {
            caVente += l.totalLigne;
          } else {
            caService += l.totalLigne;
          }
        }
      } else {
        // Fallback : tout en service (cas micro-entrepreneur artisan par défaut)
        caService += f.totalHt;
      }
    }

    return (caVente: caVente, caService: caService);
  }

  /// Vérifie si un montant de document supplémentaire déclencherait un dépassement.
  ///
  /// Utile pour alerter dans les steppers AVANT finalisation.
  static BilanTva simulerAvecMontant({
    required Decimal caVenteYtd,
    required Decimal caServiceYtd,
    required Decimal montantSupplementaire,
    required bool estVente,
    required UrssafConfig config,
  }) {
    final newVente = estVente ? caVenteYtd + montantSupplementaire : caVenteYtd;
    final newService =
        estVente ? caServiceYtd : caServiceYtd + montantSupplementaire;

    return analyser(
      caVenteYtd: newVente,
      caServiceYtd: newService,
      config: config,
    );
  }

  /// Détermine si un type d'activité relève de la vente de marchandises.
  static bool _isVente(String typeActivite) {
    final lower = typeActivite.toLowerCase();
    return lower == 'vente' || lower == 'marchandise' || lower == 'negoce';
  }
}
