import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:decimal/decimal.dart';

import '../viewmodels/shopping_viewmodel.dart';
import '../models/shopping_model.dart';
import '../widgets/base_screen.dart';
import '../widgets/custom_text_field.dart';
import '../utils/format_utils.dart';
import '../config/theme.dart';

class ShoppingListView extends StatefulWidget {
  const ShoppingListView({super.key});

  @override
  State<ShoppingListView> createState() => _ShoppingListViewState();
}

class _ShoppingListViewState extends State<ShoppingListView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ShoppingViewModel>(context, listen: false).fetchItems();
    });
  }

  void _ajouterItem() {
    final designationCtrl = TextEditingController();
    final quantiteCtrl = TextEditingController(text: "1");
    final prixCtrl = TextEditingController(text: "0");

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Ajouter un achat"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomTextField(label: "Désignation", controller: designationCtrl),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                    child: CustomTextField(
                        label: "Quantité",
                        controller: quantiteCtrl,
                        keyboardType: TextInputType.number)),
                const SizedBox(width: 10),
                Expanded(
                    child: CustomTextField(
                        label: "Prix Est. (€)",
                        controller: prixCtrl,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true))),
              ],
            )
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("Annuler")),
          ElevatedButton(
            onPressed: () {
              final q =
                  Decimal.tryParse(quantiteCtrl.text.replaceAll(',', '.')) ??
                      Decimal.one;
              final p = Decimal.tryParse(prixCtrl.text.replaceAll(',', '.')) ??
                  Decimal.zero;

              if (designationCtrl.text.isNotEmpty) {
                final item = ShoppingItem(
                  designation: designationCtrl.text,
                  quantite: q,
                  prixUnitaire: p,
                );
                Provider.of<ShoppingViewModel>(context, listen: false)
                    .addItem(item);
                Navigator.pop(ctx);
              }
            },
            child: const Text("Ajouter"),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<ShoppingViewModel>(context);

    // Séparation des listes
    final aAcheter = vm.items.where((i) => !i.estAchete).toList();
    final achetes = vm.items.where((i) => i.estAchete).toList();

    return BaseScreen(
      menuIndex: 6, // CORRECTION: Index Shopping
      title: "Liste de Courses",
      floatingActionButton: FloatingActionButton(
        onPressed: _ajouterItem,
        child: const Icon(Icons.add),
      ),
      child: Column(
        children: [
          // Total Panier
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Total Estimé",
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text(
                  FormatUtils.currency(vm.totalPanier),
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: AppTheme.primary),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Listes
          Expanded(
            child: vm.isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView(
                    children: [
                      if (aAcheter.isEmpty && achetes.isEmpty)
                        const Center(
                            child: Padding(
                          padding: EdgeInsets.all(20.0),
                          child: Text("Votre liste est vide"),
                        )),
                      ...aAcheter.map((item) => Dismissible(
                            key: Key(item.id ?? item.designation),
                            direction: DismissDirection.endToStart,
                            background: Container(color: Colors.red),
                            onDismissed: (_) => vm.deleteItem(item.id!),
                            child: Card(
                              child: CheckboxListTile(
                                value: item.estAchete,
                                onChanged: (_) => vm.toggleCheck(item),
                                title: Text(item.designation,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold)),
                                subtitle: Text(
                                    "${item.quantite} x ${FormatUtils.currency(item.prixUnitaire)}"),
                                secondary: const Icon(Icons.circle_outlined,
                                    color: Colors.grey),
                              ),
                            ),
                          )),
                      if (achetes.isNotEmpty) ...[
                        const Divider(height: 30),
                        const Padding(
                          padding: EdgeInsets.only(left: 16, bottom: 8),
                          child: Text("DÉJÀ ACHETÉ",
                              style: TextStyle(
                                  color: Colors.grey,
                                  fontWeight: FontWeight.bold)),
                        ),
                        ...achetes.map((item) => Dismissible(
                              key: Key(item.id ?? item.designation),
                              onDismissed: (_) => vm.deleteItem(item.id!),
                              background: Container(color: Colors.red),
                              child: Card(
                                color: Colors.grey.shade100,
                                child: CheckboxListTile(
                                  value: item.estAchete,
                                  onChanged: (_) => vm.toggleCheck(item),
                                  title: Text(
                                    item.designation,
                                    style: const TextStyle(
                                        decoration: TextDecoration.lineThrough,
                                        color: Colors.grey),
                                  ),
                                  subtitle: Text(
                                      FormatUtils.currency(item.totalLigne),
                                      style:
                                          const TextStyle(color: Colors.grey)),
                                  secondary: const Icon(Icons.check_circle,
                                      color: Colors.green),
                                ),
                              ),
                            )),
                      ]
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
