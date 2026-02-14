import 'package:flutter/material.dart';
import 'package:decimal/decimal.dart';
import 'package:intl/intl.dart';
import '../config/theme.dart';

class ChiffrageEditor extends StatefulWidget {
  final String description;
  final Decimal quantite;
  final Decimal prixAchat; // HT
  final Decimal prixVente; // HT (Estimé)
  final String unite;
  final Decimal tauxUrssaf;
  final Function(String desc, Decimal qte, Decimal pa, Decimal pv, String unite)
      onChanged;
  final VoidCallback onDelete;

  const ChiffrageEditor({
    super.key,
    required this.description,
    required this.quantite,
    required this.prixAchat,
    required this.prixVente,
    required this.unite,
    required this.tauxUrssaf,
    required this.onChanged,
    required this.onDelete,
  });

  @override
  State<ChiffrageEditor> createState() => _ChiffrageEditorState();
}

class _ChiffrageEditorState extends State<ChiffrageEditor> {
  late TextEditingController _descCtrl;
  late TextEditingController _qteCtrl;
  late TextEditingController _paCtrl;
  late TextEditingController _pvCtrl;
  late TextEditingController _uniteCtrl;

  @override
  void initState() {
    super.initState();
    _descCtrl = TextEditingController(text: widget.description);
    _qteCtrl = TextEditingController(text: widget.quantite.toString());
    _paCtrl = TextEditingController(text: widget.prixAchat.toString());
    _pvCtrl = TextEditingController(text: widget.prixVente.toString());
    _uniteCtrl = TextEditingController(text: widget.unite);
  }

  @override
  void dispose() {
    _descCtrl.dispose();
    _qteCtrl.dispose();
    _paCtrl.dispose();
    _pvCtrl.dispose();
    _uniteCtrl.dispose();
    super.dispose();
  }

  void _notify() {
    final q =
        Decimal.tryParse(_qteCtrl.text.replaceAll(',', '.')) ?? Decimal.zero;
    final pa =
        Decimal.tryParse(_paCtrl.text.replaceAll(',', '.')) ?? Decimal.zero;
    final pv =
        Decimal.tryParse(_pvCtrl.text.replaceAll(',', '.')) ?? Decimal.zero;
    widget.onChanged(_descCtrl.text, q, pa, pv, _uniteCtrl.text);
  }

  void _applyCoeff(double coeff) {
    final pa =
        Decimal.tryParse(_paCtrl.text.replaceAll(',', '.')) ?? Decimal.zero;
    final pv = pa * Decimal.parse(coeff.toString());
    _pvCtrl.text = pv.toStringAsFixed(2);
    _notify();
  }

  @override
  Widget build(BuildContext context) {
    final qte = Decimal.tryParse(_qteCtrl.text) ?? Decimal.zero;
    final pa = Decimal.tryParse(_paCtrl.text) ?? Decimal.zero;
    final pv = Decimal.tryParse(_pvCtrl.text) ?? Decimal.zero;

    final totalAchat = qte * pa;
    final totalVente = qte * pv;
    final charges = (totalVente * widget.tauxUrssaf) / Decimal.fromInt(100);
    final margeNette = totalVente - totalAchat - charges.toDecimal();
    final isPositive = margeNette >= Decimal.zero;

    final currency = NumberFormat.simpleCurrency(locale: 'fr_FR');

    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: TextField(
                    controller: _descCtrl,
                    onChanged: (_) => _notify(),
                    decoration: const InputDecoration(
                        labelText: "Désignation", isDense: true),
                  ),
                ),
                IconButton(
                    onPressed: widget.onDelete,
                    icon:
                        const Icon(Icons.delete, color: Colors.grey, size: 20))
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _qteCtrl,
                    keyboardType: TextInputType.number,
                    onChanged: (_) {
                      setState(() {});
                      _notify();
                    },
                    decoration: const InputDecoration(
                        labelText: "Qté", isDense: true, suffixText: "u"),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _paCtrl,
                    keyboardType: TextInputType.number,
                    onChanged: (_) {
                      setState(() {});
                      _notify();
                    },
                    decoration: const InputDecoration(
                        labelText: "PA Uni.", isDense: true),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _pvCtrl,
                    keyboardType: TextInputType.number,
                    onChanged: (_) {
                      setState(() {});
                      _notify();
                    },
                    decoration: const InputDecoration(
                        labelText: "PV Uni.", isDense: true),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    _buildCoeffBtn(1.3),
                    const SizedBox(width: 4),
                    _buildCoeffBtn(1.5),
                    const SizedBox(width: 4),
                    _buildCoeffBtn(2.0),
                  ],
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isPositive
                        ? Colors.green.withValues(alpha: 0.1)
                        : Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: isPositive ? Colors.green : Colors.red),
                  ),
                  child: Column(
                    children: [
                      const Text("NET POCHE",
                          style: TextStyle(
                              fontSize: 9, fontWeight: FontWeight.bold)),
                      Text(
                        currency.format(margeNette.toDouble()),
                        style: TextStyle(
                          color:
                              isPositive ? Colors.green[700] : Colors.red[700],
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildCoeffBtn(double val) {
    return InkWell(
      onTap: () => _applyCoeff(val),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(4)),
        child: Text("x$val", style: const TextStyle(fontSize: 10)),
      ),
    );
  }
}
