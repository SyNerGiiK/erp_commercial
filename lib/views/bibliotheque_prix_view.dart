import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:decimal/decimal.dart';

import '../viewmodels/article_viewmodel.dart';
import '../models/article_model.dart';
import '../widgets/base_screen.dart';
import '../widgets/app_card.dart';
import '../widgets/custom_text_field.dart';
import '../utils/format_utils.dart';
import '../config/theme.dart';

class BibliothequePrixView extends StatefulWidget {
  const BibliothequePrixView({super.key});

  @override
  State<BibliothequePrixView> createState() => _BibliothequePrixViewState();
}

class _BibliothequePrixViewState extends State<BibliothequePrixView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ArticleViewModel>(context, listen: false).fetchArticles();
    });
  }

  void _editerArticle({Article? article}) {
    final isEdit = article != null;
    final formKey = GlobalKey<FormState>();

    final designationCtrl =
        TextEditingController(text: article?.designation ?? "");
    final prixVenteCtrl = TextEditingController(
        text: article?.prixUnitaire.toDouble().toString() ?? "");
    final prixAchatCtrl = TextEditingController(
        text: article?.prixAchat.toDouble().toString() ?? "");
    final uniteCtrl = TextEditingController(text: article?.unite ?? "u");
    String typeActivite = article?.typeActivite ?? 'service';
    Decimal tauxTva = article?.tauxTva ?? Decimal.fromInt(20);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isEdit ? "Modifier" : "Nouvel Article"),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomTextField(
                  label: "Désignation",
                  controller: designationCtrl,
                  validator: (v) => v!.isEmpty ? "Requis" : null,
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                        child: CustomTextField(
                            label: "Prix Vente HT",
                            controller: prixVenteCtrl,
                            keyboardType: TextInputType.number)),
                    const SizedBox(width: 10),
                    SizedBox(
                        width: 80,
                        child: CustomTextField(
                            label: "Unité", controller: uniteCtrl)),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<Decimal>(
                        initialValue: tauxTva,
                        decoration: const InputDecoration(labelText: "TVA"),
                        items: [20.0, 10.0, 5.5, 2.1, 0.0].map((t) {
                          return DropdownMenuItem(
                            value: Decimal.parse(t.toString()),
                            child: Text("$t %"),
                          );
                        }).toList(),
                        onChanged: (v) => tauxTva = v!,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                CustomTextField(
                    label: "Prix Achat HT (Optionnel)",
                    controller: prixAchatCtrl,
                    keyboardType: TextInputType.number),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  key: ValueKey(typeActivite),
                  initialValue: typeActivite,
                  decoration: const InputDecoration(labelText: "Type"),
                  items: const [
                    DropdownMenuItem(
                        value: 'service', child: Text("Service / MO")),
                    DropdownMenuItem(
                        value: 'vente', child: Text("Matériau / Vente")),
                  ],
                  onChanged: (v) => typeActivite = v!,
                )
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("Annuler")),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                final newArticle = Article(
                  id: article?.id,
                  userId: article?.userId,
                  designation: designationCtrl.text,
                  prixUnitaire: Decimal.parse(
                      prixVenteCtrl.text.replaceAll(',', '.') == ""
                          ? "0"
                          : prixVenteCtrl.text.replaceAll(',', '.')),
                  prixAchat: Decimal.parse(
                      prixAchatCtrl.text.replaceAll(',', '.') == ""
                          ? "0"
                          : prixAchatCtrl.text.replaceAll(',', '.')),
                  unite: uniteCtrl.text,
                  typeActivite: typeActivite,
                  tauxTva: tauxTva,
                );

                final vm =
                    Provider.of<ArticleViewModel>(context, listen: false);
                if (isEdit) {
                  vm.updateArticle(newArticle);
                } else {
                  vm.addArticle(newArticle);
                }
                Navigator.pop(ctx);
              }
            },
            child: const Text("Enregistrer"),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<ArticleViewModel>(context);

    return BaseScreen(
      menuIndex: 7, // CORRIGÉ: Index 7 (Biblio)
      title: "Bibliothèque",
      subtitle: "Prix & Services",
      floatingActionButton: FloatingActionButton(
        onPressed: () => _editerArticle(),
        child: const Icon(Icons.add),
      ),
      child: vm.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: vm.articles.length,
              itemBuilder: (context, index) {
                final article = vm.articles[index];
                return AppCard(
                  onTap: () => _editerArticle(article: article),
                  leading: Icon(
                    article.typeActivite == 'service'
                        ? Icons.handyman
                        : Icons.shopping_bag,
                    color: AppTheme.primary,
                  ),
                  title: Text(article.designation),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          "Vente : ${FormatUtils.currency(article.prixUnitaire)} / ${article.unite}"),
                      if (article.prixAchat > Decimal.zero)
                        Text(
                          "Achat : ${FormatUtils.currency(article.prixAchat)}",
                          style:
                              const TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                    ],
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.grey),
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (c) => AlertDialog(
                          title: const Text("Supprimer ?"),
                          content: const Text("Cette action est irréversible."),
                          actions: [
                            TextButton(
                                onPressed: () => Navigator.pop(c, false),
                                child: const Text("Non")),
                            TextButton(
                                onPressed: () => Navigator.pop(c, true),
                                child: const Text("Oui")),
                          ],
                        ),
                      );
                      if (!mounted) return;
                      if (confirm == true && article.id != null) {
                        vm.deleteArticle(article.id!);
                      }
                    },
                  ),
                );
              },
            ),
    );
  }
}
