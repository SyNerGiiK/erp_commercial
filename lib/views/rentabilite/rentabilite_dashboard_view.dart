import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../config/theme.dart';
import '../../utils/format_utils.dart';
import '../../viewmodels/rentabilite_viewmodel.dart';
import '../../widgets/base_screen.dart';

class RentabiliteDashboardView extends StatefulWidget {
  const RentabiliteDashboardView({super.key});

  @override
  State<RentabiliteDashboardView> createState() =>
      _RentabiliteDashboardViewState();
}

class _RentabiliteDashboardViewState extends State<RentabiliteDashboardView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RentabiliteViewModel>().loadDevis();
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<RentabiliteViewModel>();

    return BaseScreen(
      menuIndex: 8,
      title: "Cockpit Chantier",
      child: vm.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Chantiers Actifs",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Expanded(
                    child: vm.devisList.isEmpty
                        ? const Center(
                            child: Text("Aucun chantier actif trouvé."))
                        : GridView.builder(
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              childAspectRatio: 1.5,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                            ),
                            itemCount: vm.devisList.length,
                            itemBuilder: (context, index) {
                              final devis = vm.devisList[index];
                              return _ChantierCard(
                                devis: devis,
                                onTap: () => context
                                    .push('/app/rentabilite/${devis.id}'),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
    );
  }
}

class _ChantierCard extends StatelessWidget {
  final dynamic devis;
  final VoidCallback onTap;

  const _ChantierCard({required this.devis, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.surfaceGlassLight,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.primary.withValues(alpha: 0.1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  devis.objet,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  "Réf. ${devis.numeroDevis}",
                  style: const TextStyle(
                      color: AppTheme.textSecondary, fontSize: 12),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Budget HT", style: TextStyle(fontSize: 12)),
                    Text(
                      FormatUtils.formatCurrency(devis.totalHt),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primary,
                      ),
                    ),
                  ],
                ),
                const Icon(Icons.arrow_forward_ios,
                    size: 16, color: AppTheme.primary),
              ],
            )
          ],
        ),
      ),
    );
  }
}
