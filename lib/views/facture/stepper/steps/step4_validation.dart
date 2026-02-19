import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:decimal/decimal.dart';

import '../../../../models/facture_model.dart';
import '../../../../viewmodels/facture_viewmodel.dart';
import '../../../../viewmodels/entreprise_viewmodel.dart';
import '../../../../viewmodels/dashboard_viewmodel.dart';
import '../../../../widgets/dialogs/signature_dialog.dart';
import '../../../../widgets/tva_alert_banner.dart';
import '../../../../config/theme.dart';
import '../../../../utils/format_utils.dart';
import '../../../../widgets/app_card.dart';

class Step4Validation extends StatefulWidget {
  final Facture facture;
  final Future<void> Function()? onFinalise;

  const Step4Validation({
    super.key,
    required this.facture,
    this.onFinalise,
  });

  @override
  State<Step4Validation> createState() => _Step4ValidationState();
}

class _Step4ValidationState extends State<Step4Validation> {
  bool _isLoading = false;

  Future<void> _signerClient() async {
    if (widget.facture.id == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Veuillez d'abord enregistrer la facture.")));
      return;
    }

    final Uint8List? signatureBytes = await showDialog(
      context: context,
      builder: (_) => const SignatureDialog(),
    );

    if (signatureBytes == null) return;
    if (!mounted) return;

    setState(() => _isLoading = true);
    final vm = Provider.of<FactureViewModel>(context, listen: false);

    final success =
        await vm.uploadSignature(widget.facture.id!, signatureBytes);

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
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
        title: const Text("Valider définitivement ?"),
        content: const Text(
            "La facture sera enregistrée, verrouillée et numérotée officiellement. Cette action est irréversible."),
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

    // Déléguer au parent (stepper) qui gère sauvegarde + finalisation
    if (widget.onFinalise != null) {
      setState(() => _isLoading = true);
      await widget.onFinalise!();
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    // Fallback si pas de callback (ne devrait pas arriver)
    setState(() => _isLoading = true);
    final vm = Provider.of<FactureViewModel>(context, listen: false);

    final success = await vm.finaliserFacture(widget.facture);

    if (mounted) setState(() => _isLoading = false);

    if (success) {
      if (mounted) {
        context.go('/app/factures');
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("Facture validée !")));
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("Erreur validation")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isTvaApplicable =
        Provider.of<EntrepriseViewModel>(context).isTvaApplicable;
    final dashboardVm = Provider.of<DashboardViewModel>(context);
    final f = widget.facture;

    return Column(
      children: [
        // Alerte TVA si dépassement détecté
        if (dashboardVm.bilanTva != null)
          TvaAlertBanner(bilan: dashboardVm.bilanTva!),

        const Text(
          "Récapitulatif",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        AppCard(
          child: Column(
            children: [
              // Contexte marché pour factures d'avancement
              if (f.type == 'situation') ...[
                _buildRow(
                    "Total Marché HT", FormatUtils.currency(_totalMarche(f)),
                    color: Colors.grey),
                _buildRow("Avancement global", "${_avancementGlobal(f)}%",
                    color: Colors.blue),
                const Divider(),
              ],
              if (isTvaApplicable) ...[
                _buildRow(
                    f.type == 'situation' ? "Travaux réalisés HT" : "Total HT",
                    FormatUtils.currency(f.totalHt)),
                if (f.totalTva > Decimal.zero)
                  _buildRow("Total TVA", FormatUtils.currency(f.totalTva)),
                const Divider(),
                _buildRow("Total TTC", FormatUtils.currency(f.totalTtc),
                    isBold: true),
              ] else
                _buildRow("Total NET", FormatUtils.currency(f.totalTtc),
                    isBold: true),
              if (f.acompteDejaRegle > Decimal.zero)
                _buildRow(
                    "Déjà réglé", FormatUtils.currency(f.acompteDejaRegle),
                    color: Colors.green),
              if (f.acompteDejaRegle > Decimal.zero)
                _buildRow("Reste à Payer", FormatUtils.currency(f.netAPayer),
                    isBold: true, color: Colors.red),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // SIGNATURE SECTION
        AppCard(
          title: const Text("SIGNATURE CLIENT"),
          child: Column(
            children: [
              if (f.signatureUrl != null)
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
                          Image.network(f.signatureUrl!, fit: BoxFit.contain),
                    ),
                    const SizedBox(height: 8),
                    Text(
                        "Signé le ${DateFormat('dd/MM/yyyy HH:mm').format(f.dateSignature ?? DateTime.now())}",
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

        // VALIDATION BUTTON
        if (f.statut == 'brouillon' && !_isLoading)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _finaliser,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 15),
              ),
              icon: const Icon(Icons.check_circle),
              label: const Text("VALIDER DÉFINITIVEMENT",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
        if (_isLoading) const Center(child: CircularProgressIndicator()),
      ],
    );
  }

  // --- Helpers situation ---

  /// Total du marché (somme qté × PU de toutes les lignes article)
  Decimal _totalMarche(Facture f) {
    return f.lignes
        .where((l) => l.type == 'article')
        .fold(Decimal.zero, (sum, l) => sum + (l.quantite * l.prixUnitaire));
  }

  /// Avancement global pondéré (totalHT / totalMarché × 100)
  String _avancementGlobal(Facture f) {
    final marche = _totalMarche(f);
    if (marche == Decimal.zero) return "0.0";
    return ((f.totalHt * Decimal.fromInt(100)) / marche)
        .toDecimal(scaleOnInfinitePrecision: 10)
        .toDouble()
        .toStringAsFixed(1);
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
