import 'dart:convert';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/facture_model.dart';
import '../models/devis_model.dart';
import '../models/client_model.dart';
import '../models/entreprise_model.dart';
import '../services/relance_service.dart';
import '../services/email_service.dart';
import '../config/supabase_config.dart';

/// Service d'envoi d'emails via Supabase Edge Function (Resend).
///
/// Remplace le fallback mailto: de [EmailService] par un envoi serveur
/// avec pièce jointe PDF automatique et audit trail intégré.
///
/// Prérequis :
///   - Edge Function `send-email` déployée sur Supabase
///   - Variable `RESEND_API_KEY` configurée dans Supabase Vault
///   - Variable `FROM_EMAIL` configurée (domaine vérifié)
///
/// Fallback : si l'Edge Function échoue, retombe sur [EmailService] (mailto:).
class EdgeEmailService {
  EdgeEmailService._();

  /// Envoie un devis par email via Edge Function.
  ///
  /// [pdfBytes] : contenu PDF du devis (optionnel, sera joint en pièce jointe).
  static Future<EmailResult> envoyerDevis({
    required Devis devis,
    required Client client,
    ProfilEntreprise? profil,
    List<int>? pdfBytes,
  }) async {
    if (client.email.isEmpty) {
      return EmailResult.error(
          "Le client ${client.nomComplet} n'a pas d'adresse email.");
    }

    final nomEntreprise = profil?.nomEntreprise ?? 'Notre entreprise';
    final subject = 'Devis ${devis.numeroDevis} - $nomEntreprise';
    final body = _buildDevisBody(devis, client, nomEntreprise);

    return _sendViaEdgeFunction(
      to: client.email,
      subject: subject,
      body: body,
      pdfBytes: pdfBytes,
      pdfFilename: '${devis.numeroDevis.replaceAll('/', '-')}.pdf',
      documentType: 'devis',
      documentId: devis.id,
      documentNumero: devis.numeroDevis,
      // Fallback mailto:
      fallback: () => EmailService.envoyerDevis(
        devis: devis,
        client: client,
        profil: profil,
      ),
    );
  }

  /// Envoie une facture par email via Edge Function.
  ///
  /// [pdfBytes] : contenu PDF de la facture (optionnel).
  static Future<EmailResult> envoyerFacture({
    required Facture facture,
    required Client client,
    ProfilEntreprise? profil,
    List<int>? pdfBytes,
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

    return _sendViaEdgeFunction(
      to: client.email,
      subject: subject,
      body: body,
      pdfBytes: pdfBytes,
      pdfFilename: '${facture.numeroFacture.replaceAll('/', '-')}.pdf',
      documentType: 'facture',
      documentId: facture.id,
      documentNumero: facture.numeroFacture,
      fallback: () => EmailService.envoyerFacture(
        facture: facture,
        client: client,
        profil: profil,
      ),
    );
  }

  /// Envoie une relance par email via Edge Function.
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
    body += '\n\n$nomEntreprise';

    return _sendViaEdgeFunction(
      to: email,
      subject: subject,
      body: body,
      documentType: 'relance',
      documentId: relance.facture.id,
      documentNumero: relance.facture.numeroFacture,
      fallback: () => EmailService.envoyerRelance(
        relance: relance,
        profil: profil,
      ),
    );
  }

  // ══════════════════════════════════════════════
  //  CORE — Appel Edge Function avec fallback
  // ══════════════════════════════════════════════

  static Future<EmailResult> _sendViaEdgeFunction({
    required String to,
    required String subject,
    required String body,
    List<int>? pdfBytes,
    String? pdfFilename,
    String? documentType,
    String? documentId,
    String? documentNumero,
    required Future<EmailResult> Function() fallback,
  }) async {
    try {
      final payload = <String, dynamic>{
        'to': to,
        'subject': subject,
        'body': body,
      };

      if (pdfBytes != null && pdfFilename != null) {
        payload['pdfBase64'] = base64Encode(pdfBytes);
        payload['pdfFilename'] = pdfFilename;
      }

      if (documentType != null) payload['documentType'] = documentType;
      if (documentId != null) payload['documentId'] = documentId;
      if (documentNumero != null) payload['documentNumero'] = documentNumero;

      final response = await SupabaseConfig.client.functions.invoke(
        'send-email',
        body: payload,
      );

      if (response.status == 200) {
        final data = response.data as Map<String, dynamic>;
        if (data['success'] == true) {
          return EmailResult.ok();
        }
        // Réponse 200 mais success: false — fallback
        return await fallback();
      }

      // Status non-200 — fallback vers mailto:
      return await fallback();
    } catch (_) {
      // Edge Function indisponible — fallback transparent vers mailto:
      return await fallback();
    }
  }

  // ══════════════════════════════════════════════
  //  Corps email (identiques à EmailService)
  // ══════════════════════════════════════════════

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

  static String _buildFactureBody(
      Facture facture, Client client, String nomEntreprise, String docLabel) {
    return '''${client.nomComplet},

Veuillez trouver ci-joint ${docLabel == 'Avoir' ? "notre avoir" : "notre facture"} ${facture.numeroFacture} relatif(e) à :
${facture.objet}

Montant HT : ${facture.totalHt.toStringAsFixed(2)} €
Montant TTC : ${facture.totalTtc.toStringAsFixed(2)} €
Date d'échéance : ${_formatDate(facture.dateEcheance)}

${docLabel == 'Avoir' ? '' : "Merci de procéder au règlement avant la date d'échéance.\n"}
Cordialement,
$nomEntreprise''';
  }

  static String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}
