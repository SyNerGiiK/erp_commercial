import 'dart:async';
import 'package:flutter/material.dart';
import 'package:decimal/decimal.dart';
import '../config/theme.dart';

class LigneEditor extends StatefulWidget {
  final String description;
  final Decimal quantite;
  final Decimal prixUnitaire;
  final String unite;
  final String type; // article, titre, sous-titre, texte, saut_page
  final bool estGras;
  final bool estItalique;
  final bool estSouligne;

  // MODULE 2: Situation
  final bool isSituation;
  final Decimal? avancement; // 0-100 (Nullable to allow default handling)

  // MODULE TVA
  final Decimal? tauxTva;
  final bool showTva; // NEW

  // Callback updated with avancement
  final Function(
      String desc,
      Decimal qte,
      Decimal pu,
      String unite,
      String type,
      bool estGras,
      bool estItalique,
      bool estSouligne,
      Decimal avancement,
      Decimal tauxTva) onChanged;

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
    this.isSituation = false,
    this.avancement,
    this.tauxTva,
    this.showTva = true,
  });

  @override
  State<LigneEditor> createState() => _LigneEditorState();
}

class _LigneEditorState extends State<LigneEditor> {
  late TextEditingController _descCtrl;
  late TextEditingController _qteCtrl;
  late TextEditingController _puCtrl;
  late TextEditingController _uniteCtrl;
  late TextEditingController _avancementCtrl;

  // State for Dropdown
  late Decimal _currentTva;

  final FocusNode _puFocus = FocusNode();
  final FocusNode _qteFocus = FocusNode();
  final FocusNode _avancementFocus = FocusNode();

  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _descCtrl = TextEditingController(text: widget.description);
    _qteCtrl = TextEditingController(text: widget.quantite.toString());
    _puCtrl = TextEditingController(text: widget.prixUnitaire.toString());
    _uniteCtrl = TextEditingController(text: widget.unite);
    _avancementCtrl = TextEditingController(
        text: (widget.avancement ?? Decimal.fromInt(100)).toString());

    if (!widget.showTva) {
      _currentTva = Decimal.zero;
    } else {
      _currentTva = widget.tauxTva ?? Decimal.fromInt(20);
    }
  }

  @override
  void didUpdateWidget(LigneEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.description != widget.description &&
        _descCtrl.text != widget.description) {
      _descCtrl.text = widget.description;
    }
    if (oldWidget.quantite != widget.quantite && !_qteFocus.hasFocus) {
      _qteCtrl.text = widget.quantite.toString();
    }
    if (oldWidget.prixUnitaire != widget.prixUnitaire && !_puFocus.hasFocus) {
      _puCtrl.text = widget.prixUnitaire.toString();
    }
    if (oldWidget.avancement != widget.avancement &&
        !_avancementFocus.hasFocus) {
      _avancementCtrl.text =
          (widget.avancement ?? Decimal.fromInt(100)).toString();
    }
  }

  @override
  void dispose() {
    _descCtrl.dispose();
    _qteCtrl.dispose();
    _puCtrl.dispose();
    _uniteCtrl.dispose();
    _avancementCtrl.dispose();
    _puFocus.dispose();
    _qteFocus.dispose();
    _avancementFocus.dispose();
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
      final av = Decimal.tryParse(_avancementCtrl.text.replaceAll(',', '.')) ??
          Decimal.zero;

      widget.onChanged(
        _descCtrl.text,
        q,
        pu,
        _uniteCtrl.text,
        widget.type,
        widget.estGras,
        widget.estItalique,
        widget.estSouligne,
        av,
        _currentTva,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.type == 'titre') return _buildTitreEditor();
    if (widget.type == 'titre') return _buildTitreEditor();
    if (widget.type == 'sous-titre') {
      return _buildSousTitreEditor(); // Module 1: Sous-titre
    }
    if (widget.type == 'texte') return _buildTexteEditor();
    if (widget.type == 'saut_page') {
      return _buildSautPageEditor(); // Module 1: Saut de page
    }

    // Mode Article Standard
    return widget.readOnly ? _buildReadOnly() : _buildEditable();
  }

  Widget _buildEditable() {
    // Calculs locaux pour affichage temps réel
    final q =
        Decimal.tryParse(_qteCtrl.text.replaceAll(',', '.')) ?? Decimal.zero;
    final pu =
        Decimal.tryParse(_puCtrl.text.replaceAll(',', '.')) ?? Decimal.zero;
    final av = Decimal.tryParse(_avancementCtrl.text.replaceAll(',', '.')) ??
        Decimal.zero;

    // Si situation : Total = Qte * PU * (Av / 100)
    // Sinon : Total = Qte * PU
    Decimal total;
    if (widget.isSituation) {
      total = ((q * pu * av) / Decimal.fromInt(100)).toDecimal();
    } else {
      total = q * pu;
    }

    // Astuce pour affichage : toDouble()
    final localTotalStr = total.toDouble().toStringAsFixed(2);
    final totalMarcheStr = (q * pu).toDouble().toStringAsFixed(2);

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
                  readOnly: widget.isSituation, // Bloqué en situation ?
                  // En général, on peut ajuster la description (ex: "Travaux peinture (90%)")
                  // Mais le texte de base doit rester cohérent avec le marché.
                  // Laissons éditable pour la flexibilité.
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
                if (!widget.readOnly)
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
                            widget.estSouligne,
                            av,
                            _currentTva),
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
                            widget.estSouligne,
                            av,
                            _currentTva),
                        child: Icon(Icons.format_italic,
                            size: 16,
                            color: widget.estItalique
                                ? Colors.black
                                : Colors.grey),
                      ),
                    ],
                  )
              ],
            ),
          ),

          const SizedBox(width: 4),

          // TVA - HIDDEN if showTva is false
          if (widget.showTva)
            SizedBox(
              width: 50,
              child: DropdownButtonFormField<Decimal>(
                initialValue: _currentTva,
                icon: const SizedBox(), // Cache l'icone pour gagner place
                decoration: const InputDecoration(
                  labelText: "TVA",
                  isDense: true,
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 0, vertical: 8),
                  border: InputBorder.none,
                ),
                style: const TextStyle(fontSize: 10, color: Colors.black),
                items: [20.0, 10.0, 5.5, 2.1, 0.0].map((t) {
                  return DropdownMenuItem(
                    value: Decimal.parse(t.toString()),
                    child: Text("${t.toDouble()}%",
                        style: const TextStyle(fontSize: 10)),
                  );
                }).toList(),
                onChanged: (v) {
                  if (v != null) {
                    setState(() {
                      _currentTva = v;
                    });
                    _notify();
                  }
                },
              ),
            ),

          const SizedBox(width: 4),

          const SizedBox(width: 8),

          if (widget.isSituation) ...[
            // MODE SITUATION

            // Total Marché (Info)
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text("Marché",
                    style: TextStyle(fontSize: 10, color: Colors.grey)),
                Text(totalMarcheStr,
                    style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
            const SizedBox(width: 8),

            // Avancement % (Input)
            SizedBox(
              width: 60,
              child: TextField(
                controller: _avancementCtrl,
                focusNode: _avancementFocus,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                onChanged: (_) {
                  setState(() {});
                  _notify();
                },
                decoration: const InputDecoration(
                    labelText: "%",
                    isDense: true,
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                    border: OutlineInputBorder()),
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue),
              ),
            ),
          ] else ...[
            // MODE STANDARD

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
          ],

          // Total (Calculé localement)
          const SizedBox(width: 4),
          Container(
            width: 70,
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            alignment: Alignment.centerRight,
            child: Text(
              "$localTotalStr €",
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
    Decimal total;
    if (widget.isSituation) {
      total = ((widget.quantite *
                  widget.prixUnitaire *
                  (widget.avancement ?? Decimal.fromInt(100))) /
              Decimal.fromInt(100))
          .toDecimal();
    } else {
      total = widget.quantite * widget.prixUnitaire;
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.black12)),
      ),
      child: Row(
        children: [
          Expanded(
              flex: 5,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.description,
                      style: TextStyle(
                        fontWeight: widget.estGras
                            ? FontWeight.bold
                            : FontWeight.normal,
                        fontStyle: widget.estItalique
                            ? FontStyle.italic
                            : FontStyle.normal,
                      ),
                    ),
                    if (widget.isSituation)
                      Text("Avancement: ${widget.avancement ?? 100}%",
                          style:
                              const TextStyle(fontSize: 11, color: Colors.blue))
                  ])),
          if (!widget.isSituation) ...[
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
          ],
          SizedBox(
              width: 70,
              child: Text(total.toDouble().toStringAsFixed(2),
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

  Widget _buildSousTitreEditor() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.only(left: 30, top: 4, bottom: 4, right: 8),
      color: Colors.grey.shade50,
      child: Row(
        children: [
          if (widget.showHandle)
            const Icon(Icons.drag_handle, color: Colors.grey),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _descCtrl,
              onChanged: (_) => _notify(),
              style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  decoration: TextDecoration.underline),
              decoration: const InputDecoration(
                hintText: "Sous-titre de section",
                border: InputBorder.none,
                isDense: true,
              ),
            ),
          ),
          if (!widget.readOnly)
            IconButton(
                onPressed: widget.onDelete,
                icon: const Icon(Icons.close, size: 18, color: Colors.red)),
        ],
      ),
    );
  }

  Widget _buildSautPageEditor() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      height: 40,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        border:
            Border.all(color: Colors.grey.shade400, style: BorderStyle.solid),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          const Text(
            "--- SAUT DE PAGE ---",
            style: TextStyle(
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
                color: Colors.grey),
          ),
          if (!widget.readOnly)
            Positioned(
              right: 0,
              child: IconButton(
                  onPressed: widget.onDelete,
                  icon: const Icon(Icons.close, color: Colors.red)),
            ),
          if (widget.showHandle)
            const Positioned(
              left: 8,
              child: Icon(Icons.drag_handle, color: Colors.grey),
            ),
        ],
      ),
    );
  }
}
