import 'dart:async';
import 'package:flutter/material.dart';
import 'package:decimal/decimal.dart';
import '../config/theme.dart';

class LigneEditor extends StatefulWidget {
  final String description;
  final Decimal quantite;
  final Decimal prixUnitaire;
  final String unite;
  final String type;
  final bool estGras;
  final bool estItalique;
  final bool estSouligne;

  final Function(String desc, Decimal qte, Decimal pu, String unite,
      String type, bool estGras, bool estItalique, bool estSouligne) onChanged;

  final VoidCallback onDelete;
  final bool readOnly;
  final bool showHandle;

  const LigneEditor({
    super.key,
    required this.description,
    required this.quantite,
    required this.prixUnitaire,
    required this.unite,
    required this.type,
    required this.estGras,
    required this.estItalique,
    this.estSouligne = false,
    required this.onChanged,
    required this.onDelete,
    this.readOnly = false,
    this.showHandle = false,
  });

  @override
  State<LigneEditor> createState() => _LigneEditorState();
}

class _LigneEditorState extends State<LigneEditor> {
  late TextEditingController _descCtrl;
  late TextEditingController _qteCtrl;
  late TextEditingController _puCtrl;
  late TextEditingController _uniteCtrl;

  final FocusNode _puFocus = FocusNode();
  final FocusNode _qteFocus = FocusNode();

  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _descCtrl = TextEditingController(text: widget.description);
    _qteCtrl = TextEditingController(text: widget.quantite.toString());
    _puCtrl = TextEditingController(text: widget.prixUnitaire.toString());
    _uniteCtrl = TextEditingController(text: widget.unite);
  }

  @override
  void didUpdateWidget(LigneEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    // On met à jour les contrôleurs seulement si la valeur a changé de l'extérieur
    // et que le champ n'a pas le focus (pour éviter de gêner la saisie)
    if (oldWidget.description != widget.description &&
        _descCtrl.text != widget.description) {
      _descCtrl.text = widget.description;
    }
    // Idem pour les chiffres, mais attention aux formats
  }

  @override
  void dispose() {
    _descCtrl.dispose();
    _qteCtrl.dispose();
    _puCtrl.dispose();
    _uniteCtrl.dispose();
    _puFocus.dispose();
    _qteFocus.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _notify() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      final q =
          Decimal.tryParse(_qteCtrl.text.replaceAll(',', '.')) ?? Decimal.zero;
      final pu =
          Decimal.tryParse(_puCtrl.text.replaceAll(',', '.')) ?? Decimal.zero;

      widget.onChanged(
        _descCtrl.text,
        q,
        pu,
        _uniteCtrl.text,
        widget.type,
        widget.estGras,
        widget.estItalique,
        widget.estSouligne,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.type == 'titre') return _buildTitreEditor();
    if (widget.type == 'texte') return _buildTexteEditor();

    // Mode Article Standard
    return widget.readOnly ? _buildReadOnly() : _buildEditable();
  }

  Widget _buildEditable() {
    final q =
        Decimal.tryParse(_qteCtrl.text.replaceAll(',', '.')) ?? Decimal.zero;
    final pu =
        Decimal.tryParse(_puCtrl.text.replaceAll(',', '.')) ?? Decimal.zero;
    final localTotal = (q * pu).toDouble().toStringAsFixed(2);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.showHandle)
            const Padding(
              padding: EdgeInsets.only(top: 12, right: 8),
              child: Icon(Icons.drag_handle, color: Colors.grey),
            ),

          Expanded(
            flex: 5,
            child: Column(
              children: [
                TextField(
                  controller: _descCtrl,
                  maxLines: null,
                  onChanged: (_) => _notify(),
                  decoration: const InputDecoration(
                    hintText: "Description",
                    border: InputBorder.none,
                    isDense: true,
                  ),
                  style: TextStyle(
                    fontWeight:
                        widget.estGras ? FontWeight.bold : FontWeight.normal,
                    fontStyle: widget.estItalique
                        ? FontStyle.italic
                        : FontStyle.normal,
                    decoration:
                        widget.estSouligne ? TextDecoration.underline : null,
                  ),
                ),
                // Options de style (mini barre d'outils)
                Row(
                  children: [
                    InkWell(
                      onTap: () => widget.onChanged(
                          _descCtrl.text,
                          q,
                          pu,
                          _uniteCtrl.text,
                          widget.type,
                          !widget.estGras,
                          widget.estItalique,
                          widget.estSouligne),
                      child: Icon(Icons.format_bold,
                          size: 16,
                          color: widget.estGras ? Colors.black : Colors.grey),
                    ),
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: () => widget.onChanged(
                          _descCtrl.text,
                          q,
                          pu,
                          _uniteCtrl.text,
                          widget.type,
                          widget.estGras,
                          !widget.estItalique,
                          widget.estSouligne),
                      child: Icon(Icons.format_italic,
                          size: 16,
                          color:
                              widget.estItalique ? Colors.black : Colors.grey),
                    ),
                  ],
                )
              ],
            ),
          ),

          const SizedBox(width: 8),

          // Quantité
          SizedBox(
            width: 60,
            child: TextField(
              controller: _qteCtrl,
              focusNode: _qteFocus,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              onChanged: (_) {
                setState(() {}); // Rebuild local pour total visuel
                _notify();
              },
              decoration: const InputDecoration(
                  labelText: "Qté",
                  isDense: true,
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                  border: OutlineInputBorder()),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13),
            ),
          ),
          const SizedBox(width: 4),

          // Unité
          SizedBox(
            width: 40,
            child: TextField(
              controller: _uniteCtrl,
              onChanged: (_) => _notify(),
              decoration: const InputDecoration(
                  labelText: "U",
                  isDense: true,
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                  border: OutlineInputBorder()),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13),
            ),
          ),
          const SizedBox(width: 4),

          // P.U
          Expanded(
            flex: 2,
            child: TextField(
              controller: _puCtrl,
              focusNode: _puFocus,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              onChanged: (_) {
                setState(() {}); // Rebuild local pour total visuel
                _notify();
              },
              decoration: const InputDecoration(
                  labelText: "P.U.",
                  isDense: true,
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                  border: OutlineInputBorder()),
              textAlign: TextAlign.end,
              style: const TextStyle(fontSize: 13),
            ),
          ),

          // Total (Calculé localement)
          const SizedBox(width: 4),
          Container(
            width: 70,
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            alignment: Alignment.centerRight,
            child: Text(
              "$localTotal €",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ),

          IconButton(
              onPressed: widget.onDelete,
              icon: const Icon(Icons.close, size: 18, color: Colors.red)),
        ],
      ),
    );
  }

  Widget _buildReadOnly() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.black12)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 5,
            child: Text(
              widget.description,
              style: TextStyle(
                fontWeight:
                    widget.estGras ? FontWeight.bold : FontWeight.normal,
                fontStyle:
                    widget.estItalique ? FontStyle.italic : FontStyle.normal,
              ),
            ),
          ),
          SizedBox(
              width: 40,
              child: Text(widget.quantite.toDouble().toString(),
                  textAlign: TextAlign.center)),
          SizedBox(
              width: 30,
              child: Text(widget.unite, textAlign: TextAlign.center)),
          SizedBox(
              width: 60,
              child: Text(widget.prixUnitaire.toDouble().toStringAsFixed(2),
                  textAlign: TextAlign.right)),
          SizedBox(
              width: 70,
              child: Text(
                  (widget.quantite * widget.prixUnitaire)
                      .toDouble()
                      .toStringAsFixed(2),
                  textAlign: TextAlign.right,
                  style: const TextStyle(fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }

  Widget _buildTitreEditor() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(8),
      color: Colors.grey.shade200,
      child: Row(
        children: [
          if (widget.showHandle)
            const Icon(Icons.drag_handle, color: Colors.grey),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _descCtrl,
              onChanged: (_) => _notify(),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              decoration: const InputDecoration(
                hintText: "TITRE DE SECTION",
                border: InputBorder.none,
              ),
            ),
          ),
          if (!widget.readOnly)
            IconButton(
                onPressed: widget.onDelete,
                icon: const Icon(Icons.close, color: Colors.red)),
        ],
      ),
    );
  }

  Widget _buildTexteEditor() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.all(8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.showHandle)
            const Icon(Icons.drag_handle, color: Colors.grey),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _descCtrl,
              maxLines: null,
              onChanged: (_) => _notify(),
              style: const TextStyle(
                  fontStyle: FontStyle.italic, color: Colors.grey),
              decoration: const InputDecoration(
                hintText: "Note ou commentaire...",
                border: InputBorder.none,
              ),
            ),
          ),
          if (!widget.readOnly)
            IconButton(
                onPressed: widget.onDelete,
                icon: const Icon(Icons.close, color: Colors.red)),
        ],
      ),
    );
  }
}
