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
              /// STORAGE PANEL
              SizedBox(
                height:
                    220, // Adjusted compact height to give bottom area more breathing room
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
                        ),
                ),
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

  const _StorageContent({
    required this.usedGb,
    required this.totalGb,
    required this.stats,
  });

  @override
  Widget build(BuildContext context) {
    final categories = stats.topCategories;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
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

        const SizedBox(height: 10),

        /// BIG NUMBER
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: '${usedGb.toStringAsFixed(1)} GB ',
                style: const TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              TextSpan(
                text: 'of ${totalGb.toStringAsFixed(0)} GB Used',
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey.shade400,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 18),

        /// MAIN MULTI-COLOR PROGRESS BAR FALLBACK
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: stats.usedFraction,
            minHeight: 8,
            backgroundColor: const Color(0xFF222225),
            color: Colors.blueAccent,
          ),
        ),

        const SizedBox(height: 20),

        /// HORIZONTAL EXPANDING BREAKDOWN CARDS
        Expanded(
          child: categories.isNotEmpty
              ? Row(
                  children: List.generate(categories.length, (i) {
                    final cat = categories[i];

                    return Expanded(
                      child: Container(
                        margin: EdgeInsets.only(
                          right: i == categories.length - 1 ? 0 : 12,
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF131316),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            /// VERTICAL COLORED INDICATOR BAR
                            Container(
                              width: 4,
                              height:
                                  32, // Stretched tall to look exactly like the mockup
                              decoration: BoxDecoration(
                                color: StorageService.barColorAt(i),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),

                            const SizedBox(width: 12),

                            /// TEXT CONTENT (NAME ABOVE, SIZE BELOW)
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    cat.name.toUpperCase(),
                                    style: TextStyle(
                                      color: Colors.grey.shade500,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.6,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    cat.formattedSize,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                )
              : Center(
                  child: Text(
                    'Could not read folder sizes',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                  ),
                ),
        ),
      ],
    );
  }
}
