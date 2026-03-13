import 'package:flutter/material.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final int? count;
  final Color? countColor;

  const SectionHeader({super.key, required this.title, this.count, this.countColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Row(
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          if (count != null && count! > 0) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: (countColor ?? Theme.of(context).colorScheme.primary)
                  .withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$count',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: countColor ?? Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
