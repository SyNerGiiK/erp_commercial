import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../widgets/aurora/aurora_background.dart';
import 'custom_drawer.dart';
import 'custom_app_bar.dart';

/// Écran de base Aurora 2030 — fond ambiant + sidebar glass + contenu centré.
class BaseScreen extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;
  final Widget? floatingActionButton;
  final List<Widget>? headerActions;
  final int menuIndex;
  final Widget? bottomSheet;
  final bool useFullWidth;
  final PreferredSizeWidget? appBarBottom;

  const BaseScreen({
    super.key,
    required this.title,
    this.subtitle = "",
    required this.child,
    this.floatingActionButton,
    this.headerActions,
    this.menuIndex = -1,
    this.bottomSheet,
    this.useFullWidth = false,
    this.appBarBottom,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isDesktop = width >= 1024;

    final appBar = CustomAppBar(
      title: title,
      actions: headerActions,
      bottom: appBarBottom,
    );

    final bodyContent = AuroraBackground(
      child: Column(
        children: [
          if (subtitle.isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.7),
                border: Border(
                  bottom: BorderSide(
                    color: AppTheme.divider.withValues(alpha: 0.3),
                  ),
                ),
              ),
              child: Text(
                subtitle.toUpperCase(),
                style: const TextStyle(
                  fontSize: 11,
                  color: AppTheme.textLight,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          Expanded(
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: useFullWidth ? 1200 : 800,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: child,
                ),
              ),
            ),
          ),
        ],
      ),
    );

    return Scaffold(
      appBar: appBar,
      drawer: isDesktop ? null : CustomDrawer(selectedIndex: menuIndex),
      body: isDesktop
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 260,
                  child: CustomDrawer(
                    selectedIndex: menuIndex,
                    isPermanent: true,
                  ),
                ),
                Expanded(child: bodyContent),
              ],
            )
          : bodyContent,
      floatingActionButton: floatingActionButton,
      bottomSheet: bottomSheet,
    );
  }
}
