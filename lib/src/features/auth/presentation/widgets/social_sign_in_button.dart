import 'package:flutter/material.dart';

/// Button for social sign-in options (Apple, Google, etc.)
class SocialSignInButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final IconData icon;
  final String label;

  const SocialSignInButton({
    super.key,
    required this.onPressed,
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(
        icon,
        size: 24,
        color: isDark ? Colors.white : Colors.black,
      ),
      label: Text(
        label,
        style: TextStyle(
          color: isDark ? Colors.white : Colors.black,
        ),
      ),
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(double.infinity, 52),
        side: BorderSide(
          color: isDark ? Colors.white30 : Colors.black26,
        ),
      ),
    );
  }
}
