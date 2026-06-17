import 'package:disklens/Theme/app_theme.dart';
import 'package:flutter/material.dart';

class StorageLoading extends StatelessWidget {
  const StorageLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Storage Overview',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 1.5,
                    color: Colors.grey.shade500,
                  ),
                ),
                const SizedBox(width: 12),
                Flexible(
                  child: Text(
                    'Scanning storage…',
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _bar(widthFactor: 0.45, height: 6),
            const SizedBox(height: 6),
            _bar(widthFactor: 0.2, height: 4),
            if (constraints.maxHeight > 130) ...[
              const SizedBox(height: 14),
              Text(
                'Storage breakdown',
                style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: ClipRect(
                  child: LayoutBuilder(
                    builder: (context, inner) {
                      const rowHeight = 16.0;
                      final count = (inner.maxHeight / rowHeight)
                          .floor()
                          .clamp(0, 4);

                      return Column(
                        children: List.generate(count, (i) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Row(
                              children: [
                                _box(width: 72, height: 8),
                                const SizedBox(width: 10),
                                Expanded(child: _box(height: 5)),
                                const SizedBox(width: 10),
                                _box(width: 40, height: 8),
                              ],
                            ),
                          );
                        }),
                      );
                    },
                  ),
                ),
              ),
            ] else
              const Spacer(),
          ],
        );
      },
    );
  }

  Widget _bar({required double widthFactor, required double height}) {
    return FractionallySizedBox(
      widthFactor: widthFactor,
      alignment: Alignment.centerLeft,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(3),
          color: AppTheme.cardSecondary,
        ),
      ),
    );
  }

  Widget _box({double? width, required double height}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(3),
        color: AppTheme.cardSecondary,
      ),
    );
  }
}
