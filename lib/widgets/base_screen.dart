import 'package:flutter/material.dart';
import '../config/theme.dart';
import 'custom_drawer.dart';
import 'custom_app_bar.dart';

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
    final isLargeScreen = MediaQuery.of(context).size.width > 900;

    final appBar = CustomAppBar(
      title: title,
      actions: headerActions,
      bottom: appBarBottom,
    );

    final bodyContent = Container(
      color: AppTheme.background,
      child: Column(
        children: [
          if (subtitle.isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              // Correctif : Couleur déplacée dans BoxDecoration
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
              ),
              child: Text(
                subtitle.toUpperCase(),
                style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.textLight,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.2),
                textAlign: TextAlign.center,
              ),
            ),
          Expanded(
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: useFullWidth ? double.infinity : 1200,
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
      drawer: isLargeScreen ? null : CustomDrawer(selectedIndex: menuIndex),
      body: isLargeScreen
          ? Row(
              children: [
                SizedBox(
                  width: 280,
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
