import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../config/theme.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final PreferredSizeWidget? bottom;
  final double height;

  const CustomAppBar({
    super.key,
    required this.title,
    this.actions,
    this.bottom,
    this.height = kToolbarHeight,
  });

  @override
  Widget build(BuildContext context) {
    final List<Widget> finalActions = [
      IconButton(
        icon: const Icon(Icons.search),
        tooltip: "Rechercher",
        style: IconButton.styleFrom(
          backgroundColor: Colors.white.withValues(alpha: 0.15),
          shape: const CircleBorder(),
        ),
        onPressed: () => context.push('/app/search'),
      ),
      const SizedBox(width: 8),
      if (actions != null) ...actions!,
      const SizedBox(width: 8),
    ];

    return AppBar(
      title: Text(title),
      centerTitle: true,
      actions: finalActions,
      bottom: bottom,
      iconTheme: const IconThemeData(color: Colors.white),
      titleTextStyle: const TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.0,
      ),
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.primaryGradient,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize =>
      Size.fromHeight(height + (bottom?.preferredSize.height ?? 0));
}
