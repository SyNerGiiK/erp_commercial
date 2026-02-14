import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/article_viewmodel.dart';
import '../models/article_model.dart';
import '../config/theme.dart';
import '../utils/format_utils.dart';

class ArticleSelectionDialog extends StatefulWidget {
  const ArticleSelectionDialog({super.key});

  @override
  State<ArticleSelectionDialog> createState() => _ArticleSelectionDialogState();
}

class _ArticleSelectionDialogState extends State<ArticleSelectionDialog> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ArticleViewModel>(context, listen: false).fetchArticles();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final articleVM = Provider.of<ArticleViewModel>(context);

    final filteredList = articleVM.articles.where((a) {
      final q = _searchQuery.toLowerCase();
      return a.designation.toLowerCase().contains(q);
    }).toList();

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text("Choisir un article"),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Rechercher...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              onChanged: (val) => setState(() => _searchQuery = val),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: filteredList.isEmpty
                  ? const Center(child: Text("Aucun article trouvé"))
                  : ListView.separated(
                      shrinkWrap: true,
                      itemCount: filteredList.length,
                      separatorBuilder: (ctx, i) => const Divider(),
                      itemBuilder: (context, index) {
                        final article = filteredList[index];
                        return ListTile(
                          title: Text(
                            article.designation,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            "${FormatUtils.currency(article.prixUnitaire)} / ${article.unite}",
                          ),
                          leading: Icon(
                            article.typeActivite == 'service'
                                ? Icons.handyman
                                : Icons.shopping_bag,
                            color: article.typeActivite == 'service'
                                ? Colors.blue
                                : Colors.purple,
                          ),
                          onTap: () => Navigator.pop(context, article),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, null),
          child: const Text("Annuler"),
        ),
      ],
    );
  }
}
