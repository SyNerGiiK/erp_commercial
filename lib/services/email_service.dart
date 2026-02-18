import 'package:url_launcher/url_launcher.dart';
import '../models/facture_model.dart';
import '../models/devis_model.dart';
import '../models/client_model.dart';
import '../models/entreprise_model.dart';
import '../services/relance_service.dart';
import '../services/audit_service.dart';

/// Résultat d'un envoi email
class EmailResult {
  final bool success;
  final String? errorMessage;

  const EmailResult({required this.success, this.errorMessage});

  factory EmailResult.ok() => const EmailResult(success: true);
  factory EmailResult.error(String msg) =>
      EmailResult(success: false, errorMessage: msg);
}

/// Service d'envoi d'emails via mailto: (url_launcher).
///
/// V1 : ouvre le client mail natif avec sujet/corps pré-remplis.
/// Le PDF doit être joint manuellement par l'utilisateur.
class EmailService {
  /// Envoie un devis par email
  static Future<EmailResult> envoyerDevis({
    required Devis devis,
    required Client client,
    ProfilEntreprise? profil,
  }) async {
    if (client.email.isEmpty) {
      return EmailResult.error(
          "Le client ${client.nomComplet} n'a pas d'adresse email.");
    }

    final nomEntreprise = profil?.nomEntreprise ?? 'Notre entreprise';
    final subject = 'Devis ${devis.numeroDevis} - $nomEntreprise';
    final body = _buildDevisBody(devis, client, nomEntreprise);

    final result = await _launchMailto(
      to: client.email,
      subject: subject,
      body: body,
    );

    // Log audit si succès
    if (result.success && devis.id != null) {
      AuditService.logEnvoiEmail(
        tableName: 'devis',
        recordId: devis.id!,
        destinataire: client.email,
        numeroDocument: devis.numeroDevis,
      );
    }

    return result;
  }

  /// Envoie une facture par email
  static Future<EmailResult> envoyerFacture({
    required Facture facture,
    required Client client,
    ProfilEntreprise? profil,
  }) async {
    if (client.email.isEmpty) {
      return EmailResult.error(
          "Le client ${client.nomComplet} n'a pas d'adresse email.");
    }

    final nomEntreprise = profil?.nomEntreprise ?? 'Notre entreprise';
    final isAvoir = facture.typeDocument == 'avoir' || facture.type == 'avoir';
    final docLabel = isAvoir ? 'Avoir' : 'Facture';
    final subject = '$docLabel ${facture.numeroFacture} - $nomEntreprise';
    final body = _buildFactureBody(facture, client, nomEntreprise, docLabel);

    final result = await _launchMailto(
      to: client.email,
      subject: subject,
      body: body,
    );

    // Log audit si succès
    if (result.success && facture.id != null) {
      AuditService.logEnvoiEmail(
        tableName: 'factures',
        recordId: facture.id!,
        destinataire: client.email,
        numeroDocument: facture.numeroFacture,
      );
    }

    return result;
  }

  /// Envoie une relance par email
  static Future<EmailResult> envoyerRelance({
    required RelanceInfo relance,
    ProfilEntreprise? profil,
  }) async {
    final email = relance.client?.email;
    if (email == null || email.isEmpty) {
      return EmailResult.error(
          "Le client n'a pas d'adresse email pour la relance.");
    }

    final nomEntreprise = profil?.nomEntreprise ?? 'Notre entreprise';
    final texte = RelanceService.genererTexteRelance(relance);

    // Extraire l'objet du texte généré (première ligne "Objet : ...")
    String subject;
    String body;
    if (texte.startsWith('Objet : ')) {
      final firstNewline = texte.indexOf('\n');
      if (firstNewline > 0) {
        subject = texte.substring(8, firstNewline).trim();
        body = texte.substring(firstNewline + 1).trim();
      } else {
        subject = texte.substring(8).trim();
        body = '';
      }
    } else {
      subject =
          'Relance - Facture ${relance.facture.numeroFacture} - $nomEntreprise';
      body = texte;
    }

    // Ajouter signature
    body += '\n\n$nomEntreprise';

    return _launchMailto(
      to: email,
      subject: subject,
      body: body,
    ).then((result) {
      // Log audit si succès
      if (result.success && relance.facture.id != null) {
        AuditService.logRelance(
          factureId: relance.facture.id!,
          niveauRelance: relance.niveau.name,
          destinataire: email,
          numeroFacture: relance.facture.numeroFacture,
          joursRetard: relance.joursRetard,
          montantImpaye: relance.resteAPayer.toDouble(),
        );
      }
      return result;
    });
  }

  // ── Corps email devis ──

  static String _buildDevisBody(
      Devis devis, Client client, String nomEntreprise) {
    return '''${client.nomComplet},

Veuillez trouver ci-joint notre devis ${devis.numeroDevis} relatif à :
${devis.objet}

Montant HT : ${devis.totalHt.toStringAsFixed(2)} €
Montant TTC : ${devis.totalTtc.toStringAsFixed(2)} €

Ce devis est valable jusqu'au ${_formatDate(devis.dateValidite)}.

N'hésitez pas à nous contacter pour toute question.

Cordialement,
$nomEntreprise''';
  }

  // ── Corps email facture ──

  static String _buildFactureBody(
      Facture facture, Client client, String nomEntreprise, String docLabel) {
    return '''${client.nomComplet},

Veuillez trouver ci-joint ${docLabel == 'Avoir' ? "notre avoir" : "notre facture"} ${facture.numeroFacture} relatif(e) à :
${facture.objet}

Montant HT : ${facture.totalHt.toStringAsFixed(2)} €
Montant TTC : ${facture.totalTtc.toStringAsFixed(2)} €
Date d'échéance : ${_formatDate(facture.dateEcheance)}

${docLabel == 'Avoir' ? '' : 'Merci de procéder au règlement avant la date d\'échéance.\n'}
Cordialement,
$nomEntreprise''';
  }

  // ── Helpers ──

  static String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  /// Lance l'URI mailto:
  static Future<EmailResult> _launchMailto({
    required String to,
    required String subject,
    required String body,
  }) async {
    // Construire le mailto: manuellement pour éviter les problèmes d'encodage
    final queryParams = _encodeQueryParameters({
      'subject': subject,
      'body': body,
    });
    final uri = Uri.parse('mailto:$to?$queryParams');

    try {
      // Sur Flutter Web, canLaunchUrl retourne souvent false pour mailto:
      // On tente directement le lancement avec mode externe
      await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      return EmailResult.ok();
    } catch (e) {
      // Fallback : tenter sans mode spécifique
      try {
        await launchUrl(uri);
        return EmailResult.ok();
      } catch (e2) {
        return EmailResult.error("Impossible d'ouvrir le client email: $e2");
      }
    }
  }

  /// Encode les query parameters pour mailto: correctement
  static String _encodeQueryParameters(Map<String, String> params) {
    return params.entries
        .map((e) =>
            '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
        .join('&');
  }
}
