import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:decimal/decimal.dart';

import '../../../../models/devis_model.dart';
import '../../../../viewmodels/devis_viewmodel.dart';
import '../../../../viewmodels/entreprise_viewmodel.dart';
import '../../../../widgets/dialogs/signature_dialog.dart';
import '../../../../config/theme.dart';
import '../../../../utils/format_utils.dart';
import '../../../../widgets/app_card.dart';

class DevisStep4Validation extends StatefulWidget {
  final Devis devis;

  const DevisStep4Validation({
    super.key,
    required this.devis,
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
            "Un numéro définitif sera attribué. Le devis ne sera plus modifiable."),
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

    setState(() => _isLoading = true);
    final vm = Provider.of<DevisViewModel>(context, listen: false);

    final success = await vm.finaliserDevis(widget.devis);

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      if (mounted) {
        context.go('/app/devis');
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("Devis validé !")));
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
    final d = widget.devis;

    return Column(
      children: [
        const Text(
          "Récapitulatif",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        AppCard(
          child: Column(
            children: [
              _buildRow("Total HT", FormatUtils.currency(d.totalHt)),
              if (isTvaApplicable && d.totalTva > Decimal.zero)
                _buildRow("Total TVA", FormatUtils.currency(d.totalTva)),
              const Divider(),
              _buildRow("Total TTC", FormatUtils.currency(d.totalTtc),
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

        // VALIDATION BUTTON (Si pas encore validé/signé/envoyé)
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
              icon: const Icon(Icons.check_circle),
              label: const Text("FINALISER LE DEVIS",
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
