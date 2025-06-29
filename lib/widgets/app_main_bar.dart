import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class AppMainBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final List<Widget>? actions;
  final Color? backgroundColor;

  const AppMainBar({
    this.title,
    this.actions,
    this.backgroundColor,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title ?? 'Reinserta'),
      backgroundColor: backgroundColor ?? AppColors.primary,
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}