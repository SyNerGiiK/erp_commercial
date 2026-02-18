import 'package:flutter_test/flutter_test.dart';
import 'package:erp_commercial/models/entreprise_model.dart';

void main() {
  group('ProfilEntreprise — nouveaux champs Sprint 9.3', () {
    ProfilEntreprise baseProfil({
      String? pdfPrimaryColor,
      String? logoFooterUrl,
    }) {
      return ProfilEntreprise(
        nomEntreprise: 'Test SARL',
        nomGerant: 'Jean Dupont',
        adresse: '1 rue de la Paix',
        codePostal: '75001',
        ville: 'Paris',
        siret: '12345678901234',
        email: 'test@test.fr',
        pdfPrimaryColor: pdfPrimaryColor,
        logoFooterUrl: logoFooterUrl,
      );
    }

    test('pdfPrimaryColor est null par défaut', () {
      final profil = baseProfil();
      expect(profil.pdfPrimaryColor, isNull);
    });

    test('logoFooterUrl est null par défaut', () {
      final profil = baseProfil();
      expect(profil.logoFooterUrl, isNull);
    });

    test('pdfPrimaryColor est correctement initialisé', () {
      final profil = baseProfil(pdfPrimaryColor: 'FF5733');
      expect(profil.pdfPrimaryColor, 'FF5733');
    });

    test('logoFooterUrl est correctement initialisé', () {
      final profil = baseProfil(logoFooterUrl: 'https://example.com/logo.png');
      expect(profil.logoFooterUrl, 'https://example.com/logo.png');
    });

    group('fromMap', () {
      test('parse pdf_primary_color depuis la map', () {
        final map = {
          'nom_entreprise': 'Test',
          'nom_gerant': 'Jean',
          'adresse': '1 rue',
          'code_postal': '75001',
          'ville': 'Paris',
          'siret': '12345678901234',
          'email': 'test@test.fr',
          'pdf_primary_color': '2E86C1',
          'logo_footer_url': 'https://cdn.example.com/footer.png',
        };

        final profil = ProfilEntreprise.fromMap(map);

        expect(profil.pdfPrimaryColor, '2E86C1');
        expect(profil.logoFooterUrl, 'https://cdn.example.com/footer.png');
      });

      test('gère l\'absence de pdf_primary_color (null)', () {
        final map = {
          'nom_entreprise': 'Test',
          'nom_gerant': 'Jean',
          'adresse': '1 rue',
          'code_postal': '75001',
          'ville': 'Paris',
          'siret': '12345678901234',
          'email': 'test@test.fr',
        };

        final profil = ProfilEntreprise.fromMap(map);

        expect(profil.pdfPrimaryColor, isNull);
        expect(profil.logoFooterUrl, isNull);
      });
    });

    group('toMap', () {
      test('sérialise pdf_primary_color et logo_footer_url', () {
        final profil = baseProfil(
          pdfPrimaryColor: 'E74C3C',
          logoFooterUrl: 'https://logo.test/img.jpg',
        );
        final map = profil.toMap();

        expect(map['pdf_primary_color'], 'E74C3C');
        expect(map['logo_footer_url'], 'https://logo.test/img.jpg');
      });

      test('sérialise null si pas de couleur', () {
        final profil = baseProfil();
        final map = profil.toMap();

        expect(map['pdf_primary_color'], isNull);
        expect(map['logo_footer_url'], isNull);
      });
    });

    group('copyWith', () {
      test('copie avec nouvelle couleur PDF', () {
        final original = baseProfil(pdfPrimaryColor: 'AABB00');
        final copie = original.copyWith(pdfPrimaryColor: 'FF0000');

        expect(copie.pdfPrimaryColor, 'FF0000');
        expect(copie.nomEntreprise, original.nomEntreprise);
      });

      test('copyWith sans changer conserve la valeur', () {
        final original = baseProfil(
          pdfPrimaryColor: '123456',
          logoFooterUrl: 'https://cdn.test/f.png',
        );
        final copie = original.copyWith(nomGerant: 'Marie');

        expect(copie.pdfPrimaryColor, '123456');
        expect(copie.logoFooterUrl, 'https://cdn.test/f.png');
        expect(copie.nomGerant, 'Marie');
      });
    });
  });
}
