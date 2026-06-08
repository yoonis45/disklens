import 'package:disklens/Theme/app_theme.dart';
import 'package:flutter/material.dart';

class StorageOverviewSize extends StatelessWidget {
  final String type;
  final double sizeGb;
  final Color colour;
  const StorageOverviewSize({
    super.key,
    required this.type,
    required this.sizeGb,
    required this.colour,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardSecondary,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          children: [
            Container(
              width: 4,
              height: 48,
              decoration: BoxDecoration(
                color: colour,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(type, style: const TextStyle(color: Colors.grey)),
                Text(
                  '${sizeGb.toStringAsFixed(1)} GB',
                  style: const TextStyle(fontSize: 19, color: Colors.white),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
