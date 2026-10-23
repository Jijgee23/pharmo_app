import 'package:pharmo_app/application/application.dart';

// Skeletons of the delivery screens, in each screen's shape, while there is
// nothing to show yet (a refresh of what is shown gets a RefreshLine).

/// The delivery page: tabs, the summary card, the counts and a few stops.
class DeliverySkeleton extends StatelessWidget {
  const DeliverySkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return _Skeleton(
      children: [
        const SkeletonBox(height: 44, radius: 14),
        const SizedBox(height: 14),
        _card(
          height: 168,
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  SkeletonBox(width: 64, height: 64, radius: 32),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 8,
                      children: [
                        SkeletonBox(width: 150, height: 18),
                        SkeletonBox(width: 120, height: 12),
                        SkeletonBox(width: 140, height: 12),
                      ],
                    ),
                  ),
                ],
              ),
              Spacer(),
              SkeletonBox(height: 50, radius: 14),
            ],
          ),
        ),
        const SizedBox(height: 12),
        const Row(
          spacing: 8,
          children: [
            Expanded(child: SkeletonBox(height: 64, radius: 14)),
            Expanded(child: SkeletonBox(height: 64, radius: 14)),
            Expanded(child: SkeletonBox(height: 64, radius: 14)),
            Expanded(child: SkeletonBox(height: 64, radius: 14)),
          ],
        ),
        const SizedBox(height: 22),
        const SkeletonBox(width: 120, height: 16),
        const SizedBox(height: 12),
        for (var i = 0; i < 3; i++) ...[
          _card(
            height: 150,
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    SkeletonBox(width: 44, height: 44, radius: 14),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 8,
                        children: [
                          SkeletonBox(width: 160, height: 14),
                          SkeletonBox(width: 110, height: 11),
                        ],
                      ),
                    ),
                  ],
                ),
                Spacer(),
                SkeletonBox(height: 8, radius: 4),
                SizedBox(height: 14),
                Row(
                  spacing: 8,
                  children: [
                    Expanded(child: SkeletonBox(height: 40, radius: 12)),
                    Expanded(child: SkeletonBox(height: 40, radius: 12)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
        ],
      ],
    );
  }
}

/// A stop's page: its progress card and a few order cards.
class StopOrdersSkeleton extends StatelessWidget {
  const StopOrdersSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return _Skeleton(
      children: [
        _card(
          height: 66,
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  SkeletonBox(width: 110, height: 12),
                  Spacer(),
                  SkeletonBox(width: 36, height: 12),
                ],
              ),
              Spacer(),
              SkeletonBox(height: 6, radius: 3),
            ],
          ),
        ),
        const SizedBox(height: 12),
        for (var i = 0; i < 3; i++) ...[_orderCard(), const SizedBox(height: 10)],
      ],
    );
  }

  Widget _orderCard() {
    return _card(
      height: 170,
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 8,
                  children: [
                    SkeletonBox(width: 150, height: 14),
                    SkeletonBox(width: 120, height: 11),
                  ],
                ),
              ),
              SkeletonBox(width: 80, height: 14),
            ],
          ),
          SizedBox(height: 14),
          Row(
            spacing: 6,
            children: [
              SkeletonBox(width: 110, height: 24, radius: 8),
              SkeletonBox(width: 70, height: 24, radius: 8),
              SkeletonBox(width: 70, height: 24, radius: 8),
            ],
          ),
          Spacer(),
          Row(
            spacing: 8,
            children: [
              Expanded(child: SkeletonBox(height: 40, radius: 12)),
              Expanded(child: SkeletonBox(height: 40, radius: 12)),
            ],
          ),
        ],
      ),
    );
  }
}

/// An order's detail: the tabs, the details card and the actions.
class OrderDetailSkeleton extends StatelessWidget {
  const OrderDetailSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return _Skeleton(
      children: [
        const SkeletonBox(height: 44, radius: 14),
        const SizedBox(height: 12),
        _card(
          height: 250,
          child: Column(
            children: [
              const Row(
                children: [
                  SkeletonBox(width: 110, height: 24, radius: 8),
                  Spacer(),
                  SkeletonBox(width: 100, height: 18),
                ],
              ),
              for (var i = 0; i < 5; i++) ...[
                const Spacer(),
                const Row(
                  children: [
                    SkeletonBox(width: 90, height: 12),
                    Spacer(),
                    SkeletonBox(width: 120, height: 12),
                  ],
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 14),
        const SkeletonBox(height: 52, radius: 16),
        const SizedBox(height: 10),
        const SkeletonBox(height: 52, radius: 16),
      ],
    );
  }
}

/// The ready orders: a few order cards.
class ReadyOrdersSkeleton extends StatelessWidget {
  const ReadyOrdersSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return _Skeleton(
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 16),
      children: [
        for (var i = 0; i < 6; i++) ...[
          _card(
            height: 112,
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    SkeletonBox(width: 44, height: 44, radius: 14),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 8,
                        children: [
                          SkeletonBox(width: 150, height: 14),
                          SkeletonBox(width: 120, height: 11),
                        ],
                      ),
                    ),
                    SkeletonBox(width: 76, height: 14),
                  ],
                ),
                Spacer(),
                Row(
                  spacing: 6,
                  children: [
                    SkeletonBox(width: 76, height: 22, radius: 8),
                    SkeletonBox(width: 80, height: 22, radius: 8),
                    SkeletonBox(width: 72, height: 22, radius: 8),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
        ],
      ],
    );
  }
}

/// White cards stay white; the grey boxes on them shimmer.
class _Skeleton extends StatelessWidget {
  final List<Widget> children;
  final EdgeInsets padding;
  const _Skeleton({required this.children, this.padding = const EdgeInsets.fromLTRB(16, 6, 16, 16)});

  @override
  Widget build(BuildContext context) {
    return SweepShimmer(
      blendMode: BlendMode.modulate,
      child: ListView(
        physics: const NeverScrollableScrollPhysics(),
        padding: padding,
        children: children,
      ),
    );
  }
}

Widget _card({required double height, required Widget child}) {
  return Container(
    height: height,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: white,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: grey200),
    ),
    child: child,
  );
}
