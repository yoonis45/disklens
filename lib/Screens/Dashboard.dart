import 'package:disklens/Provider/DirManager.dart';
import 'package:disklens/Service/StorageService.dart';
import 'package:disklens/Theme/app_theme.dart';
import 'package:disklens/Widgets/Listers/Grid.dart';
import 'package:disklens/Widgets/Listers/List.dart';
import 'package:disklens/Widgets/StorageLoading.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Dashboard extends StatelessWidget {
  const Dashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<Dirmanager>(
      builder: (context, manager, child) {
        final stats = manager.storageStats;
        final usedGb = stats.bytesToGb(stats.usedBytes);
        final totalGb = stats.bytesToGb(stats.totalBytes);

        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LayoutBuilder(
                builder: (context, constraints) {
                  final panelHeight = constraints.maxWidth < 700 ? 260.0 : 220.0;
                  return SizedBox(
                    height: panelHeight,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: AppTheme.card,
                      ),
                      padding: const EdgeInsets.all(20),
                      child: manager.isStorageLoading
                          ? const StorageLoading()
                          : _StorageContent(
                              usedGb: usedGb,
                              totalGb: totalGb,
                              stats: stats,
                              compact: constraints.maxWidth < 700,
                            ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
              const Text(
                'DIRECTORIES & FILES',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: manager.isGrid
                      ? Grid(entities: manager.entities)
                      : FileList(entities: manager.entities),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _StorageContent extends StatelessWidget {
  final double usedGb;
  final double totalGb;
  final StorageStats stats;
  final bool compact;

  const _StorageContent({
    required this.usedGb,
    required this.totalGb,
    required this.stats,
    required this.compact,
  });

  @override
  Widget build(BuildContext context) {
    final categories = stats.topCategories;
    final anyScanning = categories.any((c) => c.isScanning);
    final headlineSize = compact ? 26.0 : 34.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'STORAGE OVERVIEW',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            if (anyScanning) ...[
              const SizedBox(width: 10),
              SizedBox(
                width: 10,
                height: 10,
                child: CircularProgressIndicator(
                  strokeWidth: 1.5,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 10),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: '${usedGb.toStringAsFixed(1)} GB ',
                  style: TextStyle(
                    fontSize: headlineSize,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                TextSpan(
                  text: 'of ${totalGb.toStringAsFixed(0)} GB Used',
                  style: TextStyle(
                    fontSize: compact ? 13 : 15,
                    color: Colors.grey.shade400,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 18),
        _SegmentedStorageBar(stats: stats),
        const SizedBox(height: 20),
        Expanded(
          child: compact
              ? _CategoryGrid(categories: categories)
              : _CategoryRow(categories: categories),
        ),
      ],
    );
  }
}

class _CategoryRow extends StatelessWidget {
  final List<StorageCategory> categories;

  const _CategoryRow({required this.categories});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(categories.length, (i) {
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: i == categories.length - 1 ? 0 : 12),
            child: _CategoryCard(categories[i]),
          ),
        );
      }),
    );
  }
}

class _CategoryGrid extends StatelessWidget {
  final List<StorageCategory> categories;

  const _CategoryGrid({required this.categories});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 2.8,
      physics: const NeverScrollableScrollPhysics(),
      children: categories.map((c) => _CategoryCard(c)).toList(),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final StorageCategory category;

  const _CategoryCard(this.category);

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF131316),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 4,
            height: 32,
            decoration: BoxDecoration(
              color: category.isScanning
                  ? Colors.grey.shade700
                  : category.color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  category.name.toUpperCase(),
                  style: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.6,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: Text(
                    category.formattedSize,
                    key: ValueKey('${category.name}-${category.bytes}-${category.isScanning}'),
                    style: TextStyle(
                      color: category.isScanning
                          ? Colors.grey.shade600
                          : Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SegmentedStorageBar extends StatelessWidget {
  final StorageStats stats;

  const _SegmentedStorageBar({required this.stats});

  @override
  Widget build(BuildContext context) {
    final total = stats.totalBytes;
    if (total <= 0) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: const SizedBox(
          height: 10,
          child: ColoredBox(color: Color(0xFF222225)),
        ),
      );
    }

    int flexFor(int bytes) =>
        ((bytes / total) * 1000).round().clamp(bytes > 0 ? 1 : 0, 1000);

    final segments = <Widget>[];

    for (final cat in stats.topCategories) {
      if (cat.isScanning || cat.bytes <= 0) continue;
      segments.add(
        Expanded(
          flex: flexFor(cat.bytes),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOut,
            color: cat.color,
          ),
        ),
      );
    }

    final categorized = stats.categorizedBytes;
    final otherHome = (stats.homeBytes - categorized).clamp(0, stats.homeBytes);
    final otherUsed = (stats.usedBytes - stats.homeBytes).clamp(0, stats.usedBytes);
    final unbucketedHome = otherHome;

    for (final bytes in [unbucketedHome, otherUsed]) {
      final flex = flexFor(bytes);
      if (flex > 0) {
        segments.add(
          Expanded(
            flex: flex,
            child: const ColoredBox(color: Color(0xFF555558)),
          ),
        );
      }
    }

    final freeFlex = flexFor(stats.freeBytes);
    if (freeFlex > 0) {
      segments.add(
        Expanded(
          flex: freeFlex,
          child: const ColoredBox(color: Color(0xFF222225)),
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOut,
        builder: (context, value, child) {
          return SizedBox(
            height: 10,
            child: Opacity(opacity: value, child: child),
          );
        },
        child: Row(children: segments),
      ),
    );
  }
}
