import 'package:pharmo_app/application/application.dart';

/// Order cards' skeletons under one sweeping shimmer, while a list loads.
class SkeletonList extends StatelessWidget {
  final int count;
  const SkeletonList({super.key, this.count = 6});

  @override
  Widget build(BuildContext context) {
    return SweepShimmer(
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(10, 4, 10, 150),
        physics: const NeverScrollableScrollPhysics(),
        itemCount: count,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (_, __) => const _OrderCardSkeleton(),
      ),
    );
  }
}

class _OrderCardSkeleton extends StatelessWidget {
  const _OrderCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF0F0F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Avatar circle
                SkeletonBox(width: 40, height: 40, radius: 20),
                const SizedBox(width: 12),
                // Name + sub
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SkeletonBox(width: 120, height: 13, radius: 6),
                      const SizedBox(height: 6),
                      SkeletonBox(width: 80, height: 11, radius: 5),
                    ],
                  ),
                ),
                // Price + order no
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    SkeletonBox(width: 70, height: 14, radius: 6),
                    const SizedBox(height: 6),
                    SkeletonBox(width: 44, height: 11, radius: 5),
                  ],
                ),
              ],
            ),
          ),
          // Divider
          const Divider(height: 1, thickness: 1, color: Color(0xFFF3F3F3)),
          // ── Body ──────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _infoRow(130, 90),
                const SizedBox(height: 10),
                _infoRow(100, 70),
                const SizedBox(height: 12),
                // Status chips row
                Row(
                  children: [
                    SkeletonBox(width: 72, height: 24, radius: 12),
                    const SizedBox(width: 8),
                    SkeletonBox(width: 56, height: 24, radius: 12),
                    const SizedBox(width: 8),
                    SkeletonBox(width: 64, height: 24, radius: 12),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(double w1, double w2) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SkeletonBox(width: w1, height: 12, radius: 5),
          SkeletonBox(width: w2, height: 12, radius: 5),
        ],
      );
}
