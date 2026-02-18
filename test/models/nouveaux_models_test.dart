import 'package:flutter_test/flutter_test.dart';
import 'package:decimal/decimal.dart';
import 'package:erp_commercial/models/facture_recurrente_model.dart';
import 'package:erp_commercial/models/temps_activite_model.dart';
import 'package:erp_commercial/models/rappel_model.dart';

void main() {
  // ════════════════════════════════════════════
  // FACTURE RÉCURRENTE MODEL
  // ════════════════════════════════════════════

  group('FrequenceRecurrence', () {
    test('devrait avoir les bonnes valeurs de label', () {
      expect(FrequenceRecurrence.hebdomadaire.label, 'Hebdomadaire');
      expect(FrequenceRecurrence.mensuelle.label, 'Mensuelle');
      expect(FrequenceRecurrence.trimestrielle.label, 'Trimestrielle');
      expect(FrequenceRecurrence.annuelle.label, 'Annuelle');
    });

    test('devrait avoir les bons dbValues', () {
      expect(FrequenceRecurrence.hebdomadaire.dbValue, 'hebdomadaire');
      expect(FrequenceRecurrence.mensuelle.dbValue, 'mensuelle');
      expect(FrequenceRecurrence.trimestrielle.dbValue, 'trimestrielle');
      expect(FrequenceRecurrence.annuelle.dbValue, 'annuelle');
    });

    test('devrait parser depuis dbValue', () {
      expect(
        FrequenceRecurrence.values.firstWhere((e) => e.dbValue == 'mensuelle'),
        FrequenceRecurrence.mensuelle,
      );
    });
  });

  group('LigneFactureRecurrente', () {
    test('devrait créer avec les valeurs requises', () {
      final ligne = LigneFactureRecurrente(
        description: 'Prestation test',
        quantite: Decimal.fromInt(2),
        prixUnitaire: Decimal.fromInt(100),
        totalLigne: Decimal.fromInt(200),
      );
      expect(ligne.description, 'Prestation test');
      expect(ligne.quantite, Decimal.fromInt(2));
      expect(ligne.typeActivite, 'service');
      expect(ligne.tauxTva, Decimal.fromInt(20));
    });

    test('devrait sérialiser/désérialiser correctement', () {
      final ligne = LigneFactureRecurrente(
        id: 'l1',
        description: 'Test',
        quantite: Decimal.fromInt(1),
        prixUnitaire: Decimal.parse('50.00'),
        totalLigne: Decimal.parse('50.00'),
        typeActivite: 'commerce',
        tauxTva: Decimal.parse('5.5'),
      );

      final map = ligne.toMap();
      final restored = LigneFactureRecurrente.fromMap(map);

      expect(restored.id, 'l1');
      expect(restored.description, 'Test');
      expect(restored.typeActivite, 'commerce');
      expect(restored.tauxTva, Decimal.parse('5.5'));
    });
  });

  group('FactureRecurrente', () {
    test('devrait créer avec les valeurs par défaut', () {
      final fr = FactureRecurrente(
        clientId: 'c1',
        objet: 'Maintenance',
        frequence: FrequenceRecurrence.mensuelle,
        prochaineEmission: DateTime(2026, 2, 1),
        totalHt: Decimal.fromInt(500),
        totalTva: Decimal.fromInt(100),
        totalTtc: Decimal.fromInt(600),
        remiseTaux: Decimal.zero,
      );
      expect(fr.estActive, true);
      expect(fr.nbFacturesGenerees, 0);
      expect(fr.devise, 'EUR');
    });

    test('devrait sérialiser/désérialiser correctement', () {
      final original = FactureRecurrente(
        id: 'fr1',
        clientId: 'c1',
        objet: 'Abonnement SaaS',
        frequence: FrequenceRecurrence.annuelle,
        prochaineEmission: DateTime(2026, 1, 1),
        dateFin: DateTime(2028, 12, 31),
        totalHt: Decimal.fromInt(1200),
        totalTva: Decimal.fromInt(240),
        totalTtc: Decimal.fromInt(1440),
        remiseTaux: Decimal.zero,
        estActive: true,
        nbFacturesGenerees: 5,
        devise: 'USD',
        lignes: [
          LigneFactureRecurrente(
            description: 'Licence annuelle',
            quantite: Decimal.fromInt(1),
            prixUnitaire: Decimal.fromInt(1200),
            totalLigne: Decimal.fromInt(1200),
          ),
        ],
      );

      final map = original.toMap();
      final restored = FactureRecurrente.fromMap(map);

      expect(restored.id, 'fr1');
      expect(restored.objet, 'Abonnement SaaS');
      expect(restored.frequence, FrequenceRecurrence.annuelle);
      expect(restored.nbFacturesGenerees, 5);
      expect(restored.devise, 'USD');
      expect(restored.lignes, hasLength(1));
    });

    test('devrait supporter copyWith', () {
      final original = FactureRecurrente(
        clientId: 'c1',
        objet: 'Test',
        frequence: FrequenceRecurrence.mensuelle,
        prochaineEmission: DateTime(2026, 1, 1),
        totalHt: Decimal.fromInt(100),
        totalTva: Decimal.fromInt(20),
        totalTtc: Decimal.fromInt(120),
        remiseTaux: Decimal.zero,
      );

      final modified = original.copyWith(
        objet: 'Test modifié',
        estActive: false,
      );

      expect(modified.objet, 'Test modifié');
      expect(modified.estActive, false);
      expect(modified.clientId, 'c1'); // Inchangé
    });
  });

  // ════════════════════════════════════════════
  // TEMPS ACTIVITE MODEL
  // ════════════════════════════════════════════

  group('TempsActivite', () {
    test('devrait créer avec les valeurs par défaut', () {
      final t = TempsActivite(
        description: 'Dev feature',
        dateActivite: DateTime(2026, 2, 1),
        dureeMinutes: 120,
        tauxHoraire: Decimal.fromInt(50),
      );
      expect(t.estFacturable, true);
      expect(t.estFacture, false);
      expect(t.projet, '');
    });

    test('devrait calculer le montant correctement', () {
      final t = TempsActivite(
        description: 'Dev',
        dateActivite: DateTime(2026, 2, 1),
        dureeMinutes: 90, // 1h30
        tauxHoraire: Decimal.fromInt(60), // 60€/h
      );
      // 90/60 * 60 = 90€
      expect(t.montant, Decimal.fromInt(90));
    });

    test('devrait formater la durée correctement', () {
      expect(
        TempsActivite(
          description: 'A',
          dateActivite: DateTime.now(),
          dureeMinutes: 150,
          tauxHoraire: Decimal.zero,
        ).dureeFormatee,
        '2h30',
      );

      expect(
        TempsActivite(
          description: 'B',
          dateActivite: DateTime.now(),
          dureeMinutes: 60,
          tauxHoraire: Decimal.zero,
        ).dureeFormatee,
        '1h00',
      );

      expect(
        TempsActivite(
          description: 'C',
          dateActivite: DateTime.now(),
          dureeMinutes: 25,
          tauxHoraire: Decimal.zero,
        ).dureeFormatee,
        '0h25',
      );
    });

    test('devrait sérialiser/désérialiser correctement', () {
      final original = TempsActivite(
        id: 't1',
        clientId: 'c1',
        description: 'Dev API',
        projet: 'Projet Alpha',
        dateActivite: DateTime(2026, 2, 15),
        dureeMinutes: 180,
        tauxHoraire: Decimal.fromInt(75),
        estFacturable: true,
        estFacture: true,
        factureId: 'f1',
      );

      final map = original.toMap();
      final restored = TempsActivite.fromMap(map);

      expect(restored.id, 't1');
      expect(restored.clientId, 'c1');
      expect(restored.description, 'Dev API');
      expect(restored.projet, 'Projet Alpha');
      expect(restored.dureeMinutes, 180);
      expect(restored.tauxHoraire, Decimal.fromInt(75));
      expect(restored.estFacture, true);
      expect(restored.factureId, 'f1');
    });

    test('devrait supporter copyWith', () {
      final original = TempsActivite(
        description: 'Test',
        dateActivite: DateTime(2026, 1, 1),
        dureeMinutes: 60,
        tauxHoraire: Decimal.fromInt(50),
      );

      final modified = original.copyWith(
        dureeMinutes: 120,
        estFacture: true,
      );

      expect(modified.dureeMinutes, 120);
      expect(modified.estFacture, true);
      expect(modified.description, 'Test'); // Inchangé
    });
  });

  // ════════════════════════════════════════════
  // RAPPEL MODEL
  // ════════════════════════════════════════════

  group('TypeRappel', () {
    test('devrait avoir les bons labels', () {
      expect(TypeRappel.urssaf.label, 'URSSAF');
      expect(TypeRappel.cfe.label, 'CFE');
      expect(TypeRappel.tva.label, 'TVA');
      expect(TypeRappel.impots.label, 'Impôts');
      expect(TypeRappel.custom.label, 'Personnalisé');
      expect(TypeRappel.echeanceFacture.label, 'Échéance facture');
      expect(TypeRappel.finDevis.label, 'Fin validité devis');
    });

    test('devrait avoir des icônes emoji non vides', () {
      for (final type in TypeRappel.values) {
        expect(type.icon.isNotEmpty, true);
      }
    });

    test('devrait parser depuis dbValue', () {
      expect(
        TypeRappel.values.firstWhere((e) => e.dbValue == 'urssaf'),
        TypeRappel.urssaf,
      );
      expect(
        TypeRappel.values.firstWhere((e) => e.dbValue == 'custom'),
        TypeRappel.custom,
      );
    });
  });

  group('PrioriteRappel', () {
    test('devrait avoir les bons labels', () {
      expect(PrioriteRappel.basse.label, 'Basse');
      expect(PrioriteRappel.normale.label, 'Normale');
      expect(PrioriteRappel.haute.label, 'Haute');
      expect(PrioriteRappel.urgente.label, 'Urgente');
    });
  });

  group('Rappel', () {
    test('devrait créer avec les valeurs par défaut', () {
      final r = Rappel(
        titre: 'Test rappel',
        typeRappel: TypeRappel.custom,
        dateEcheance: DateTime(2026, 6, 1),
      );
      expect(r.estComplete, false);
      expect(r.priorite, PrioriteRappel.normale);
      expect(r.description, isNull);
    });

    test('devrait calculer les jours restants correctement', () {
      final futureDate = DateTime.now().add(const Duration(days: 10));
      final r = Rappel(
        titre: 'Future',
        typeRappel: TypeRappel.custom,
        dateEcheance: futureDate,
      );
      // Tolérance de 1 jour car DateTime.now() peut différer entre création et getter
      expect(r.joursRestants, closeTo(10, 1));
      expect(r.estEnRetard, false);
    });

    test('devrait détecter les rappels en retard', () {
      final pastDate = DateTime.now().subtract(const Duration(days: 5));
      final r = Rappel(
        titre: 'Retard',
        typeRappel: TypeRappel.urssaf,
        dateEcheance: pastDate,
      );
      expect(r.joursRestants, -5);
      expect(r.estEnRetard, true);
    });

    test('devrait détecter les rappels proches (< 7 jours)', () {
      final soon = DateTime.now().add(const Duration(days: 3));
      final r = Rappel(
        titre: 'Bientôt',
        typeRappel: TypeRappel.cfe,
        dateEcheance: soon,
      );
      expect(r.estProche, true);
    });

    test('ne devrait pas détecter comme proche si > 7 jours', () {
      final later = DateTime.now().add(const Duration(days: 30));
      final r = Rappel(
        titre: 'Plus tard',
        typeRappel: TypeRappel.cfe,
        dateEcheance: later,
      );
      expect(r.estProche, false);
    });

    test('devrait sérialiser/désérialiser correctement', () {
      final original = Rappel(
        id: 'r1',
        titre: 'URSSAF T2 2026',
        description: 'Déclaration trimestrielle',
        typeRappel: TypeRappel.urssaf,
        dateEcheance: DateTime(2026, 7, 31),
        priorite: PrioriteRappel.haute,
        estComplete: false,
      );

      final map = original.toMap();
      final restored = Rappel.fromMap(map);

      expect(restored.id, 'r1');
      expect(restored.titre, 'URSSAF T2 2026');
      expect(restored.description, 'Déclaration trimestrielle');
      expect(restored.typeRappel, TypeRappel.urssaf);
      expect(restored.priorite, PrioriteRappel.haute);
      expect(restored.estComplete, false);
    });

    test('devrait supporter copyWith', () {
      final original = Rappel(
        titre: 'Test',
        typeRappel: TypeRappel.custom,
        dateEcheance: DateTime(2026, 1, 1),
      );

      final modified = original.copyWith(
        titre: 'Test modifié',
        estComplete: true,
        priorite: PrioriteRappel.urgente,
      );

      expect(modified.titre, 'Test modifié');
      expect(modified.estComplete, true);
      expect(modified.priorite, PrioriteRappel.urgente);
      expect(modified.typeRappel, TypeRappel.custom); // Inchangé
    });
  });
}
