import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:decimal/decimal.dart';

import '../../../../models/devis_model.dart';
import '../../../../viewmodels/devis_viewmodel.dart';
import '../../../../viewmodels/entreprise_viewmodel.dart';
import '../../../../viewmodels/dashboard_viewmodel.dart';
import '../../../../widgets/dialogs/signature_dialog.dart';
import '../../../../widgets/tva_alert_banner.dart';
import '../../../../config/theme.dart';
import '../../../../utils/format_utils.dart';
import '../../../../widgets/app_card.dart';

class DevisStep4Validation extends StatefulWidget {
  final Devis devis;
  final void Function(String url, DateTime date)? onSignatureUpdated;
  final Future<void> Function()? onFinalise;

  const DevisStep4Validation({
    super.key,
    required this.devis,
    this.onSignatureUpdated,
    this.onFinalise,
  });

  @override
  State<DevisStep4Validation> createState() => _DevisStep4ValidationState();
}

class _DevisStep4ValidationState extends State<DevisStep4Validation> {
  bool _isLoading = false;

  Future<void> _signerClient() async {
    if (widget.devis.id == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Veuillez d'abord enregistrer le devis.")));
      return;
    }

    final Uint8List? signatureBytes = await showDialog(
      context: context,
      builder: (_) => const SignatureDialog(),
    );

    if (signatureBytes == null) return;
    if (!mounted) return;

    setState(() => _isLoading = true);
    final vm = Provider.of<DevisViewModel>(context, listen: false);

    final success = await vm.uploadSignature(widget.devis.id!, signatureBytes);

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      // Récupérer le devis mis à jour depuis le VM pour obtenir l'URL de signature
      final updatedDevis =
          vm.devis.where((d) => d.id == widget.devis.id).firstOrNull;
      if (updatedDevis?.signatureUrl != null) {
        widget.onSignatureUpdated?.call(
          updatedDevis!.signatureUrl!,
          updatedDevis.dateSignature ?? DateTime.now(),
        );
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Signature enregistrée !")));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Erreur lors de la signature")));
    }
  }

  Future<void> _finaliser() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Finaliser le devis ?"),
        content: const Text(
            "Un numéro définitif sera attribué et le client email s'ouvrira pour l'envoi."),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text("Annuler")),
          ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text("Valider")),
        ],
      ),
    );

    if (confirm != true) return;
    if (!mounted) return;

    // Déléguer au stepper parent qui gère : sauvegarde + finalisation + email
    if (widget.onFinalise != null) {
      setState(() => _isLoading = true);
      await widget.onFinalise!();
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isTvaApplicable =
        Provider.of<EntrepriseViewModel>(context).isTvaApplicable;
    final dashboardVm = Provider.of<DashboardViewModel>(context);
    final d = widget.devis;

    return Column(
      children: [
        // Alerte TVA si dépassement détecté
        if (dashboardVm.bilanTva != null)
          TvaAlertBanner(bilan: dashboardVm.bilanTva!),

        // Alerte Margin Shield
        if (d.chiffrage.isNotEmpty && d.tauxMargeBrute < Decimal.fromInt(30))
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.red.shade300),
            ),
            child: Row(
              children: [
                const Icon(Icons.shield_outlined, color: Colors.red),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "⚠️ MARGIN SHIELD : Votre taux de marge brute est de ${d.tauxMargeBrute.toStringAsFixed(1)}% (Inférieur à 30%). Risque financier détecté.",
                    style: const TextStyle(
                        color: Colors.red, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),

        const Text(
          "Récapitulatif",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        AppCard(
          child: Column(
            children: [
              if (isTvaApplicable) ...[
                _buildRow("Total HT", FormatUtils.currency(d.totalHt)),
                if (d.totalTva > Decimal.zero)
                  _buildRow("Total TVA", FormatUtils.currency(d.totalTva)),
                const Divider(),
                _buildRow("Total TTC", FormatUtils.currency(d.totalTtc),
                    isBold: true),
              ] else
                _buildRow("Total NET", FormatUtils.currency(d.totalTtc),
                    isBold: true),
              if (d.acompteMontant > Decimal.zero)
                _buildRow(
                    "Acompte demandé", FormatUtils.currency(d.acompteMontant),
                    color: Colors.blue),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // SIGNATURE SECTION
        AppCard(
          title: const Text("SIGNATURE CLIENT"),
          child: Column(
            children: [
              if (d.signatureUrl != null)
                Column(
                  children: [
                    Container(
                      height: 100,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child:
                          Image.network(d.signatureUrl!, fit: BoxFit.contain),
                    ),
                    const SizedBox(height: 8),
                    Text(
                        "Signé le ${DateFormat('dd/MM/yyyy HH:mm').format(d.dateSignature ?? DateTime.now())}",
                        style: const TextStyle(
                            color: Colors.green, fontWeight: FontWeight.bold)),
                  ],
                )
              else
                Column(
                  children: [
                    const Text("Aucune signature client",
                        style: TextStyle(color: Colors.grey)),
                    const SizedBox(height: 10),
                    if (_isLoading)
                      const CircularProgressIndicator()
                    else
                      ElevatedButton.icon(
                        onPressed: _signerClient,
                        icon: const Icon(Icons.draw),
                        label: const Text("Faire signer le client"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primary,
                          foregroundColor: Colors.white,
                        ),
                      ),
                  ],
                ),
            ],
          ),
        ),
        const SizedBox(height: 30),

        // VALIDATION BUTTON (Si brouillon)
        if ((d.statut.toLowerCase() == 'brouillon' || d.statut.isEmpty) &&
            !_isLoading)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _finaliser,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 15),
              ),
              icon: const Icon(Icons.send),
              label: const Text("FINALISER ET ENVOYER",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
        // AVENANT BUTTON (Si signe)
        if (d.statut == 'signe' && !_isLoading)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () async {
                final vm = Provider.of<DevisViewModel>(context, listen: false);
                if (d.id == null) return;
                final avenant = await vm.creerAvenant(d.id!);
                if (avenant != null && context.mounted) {
                  context.go('/app/ajout_devis/${avenant.id}', extra: avenant);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 15),
              ),
              icon: const Icon(Icons.add_circle),
              label: const Text("CRÉER UN AVENANT",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
        if (_isLoading) const Center(child: CircularProgressIndicator()),
      ],
    );
  }

  Widget _buildRow(String label, String value,
      {bool isBold = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                  color: color)),
          Text(value,
              style: TextStyle(
                  fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                  fontSize: isBold ? 18 : 16,
                  color: color)),
        ],
      ),
    );
  }
}
