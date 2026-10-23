import 'package:pharmo_app/application/app_lite.dart';

/// The app's empty state: an icon in a soft tinted halo, a title, and an
/// optional message and action.
///
/// Given a bounded height (an `Expanded`, a `Scaffold` body, a tab) it fills
/// that space and centers itself, and stays scrollable so a surrounding
/// `RefreshIndicator` can still be pulled on an empty list. In an unbounded
/// parent (a `Column` inside a scroll view) it sizes to its content.
/// [compact] never fills: use it for a section inside a page or a sheet.
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? message;

  /// Shown as a button when both are set.
  final String? actionLabel;
  final VoidCallback? onAction;
  final IconData actionIcon;

  /// Tint of the halo, icon and button; the theme's primary color by default.
  final Color? color;

  /// Smaller and padded rather than filling, for a section inside a page.
  final bool compact;

  /// Kept clear around the content while centering, e.g. the floating
  /// bottom bar on the main tabs (`EdgeInsets.only(bottom: 100)`).
  final EdgeInsets padding;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.message,
    this.actionLabel,
    this.onAction,
    this.actionIcon = Icons.refresh_rounded,
    this.color,
    this.compact = false,
    this.padding = EdgeInsets.zero,
  });

  @override
  Widget build(BuildContext context) {
    final content = Padding(padding: padding, child: _content(context));
    if (compact) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Center(child: content),
      );
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        if (!constraints.hasBoundedHeight) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 48),
            child: Center(child: content),
          );
        }
        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Center(child: content),
          ),
        );
      },
    );
  }

  Widget _content(BuildContext context) {
    final tint = color ?? context.theme.primaryColor;
    final badge = compact ? 60.0 : 88.0;
    final halo = badge + (compact ? 16 : 28);
    final hasAction = actionLabel != null && onAction != null;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutCubic,
      builder: (context, v, child) => Opacity(
        opacity: v,
        child: Transform.translate(offset: Offset(0, 16 * (1 - v)), child: child),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 320),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: halo,
                height: halo,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: tint.withValues(alpha: 0.05),
                ),
                child: Container(
                  width: badge,
                  height: badge,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [tint.withValues(alpha: 0.18), tint.withValues(alpha: 0.06)],
                    ),
                  ),
                  child: Icon(icon, size: badge * 0.45, color: tint),
                ),
              ),
              SizedBox(height: compact ? 14 : 22),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: compact ? 15 : 17,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey.shade800,
                  height: 1.3,
                ),
              ),
              if (message != null) ...[
                const SizedBox(height: 6),
                Text(
                  message!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: compact ? 12.5 : 13.5,
                    color: grey500,
                    height: 1.45,
                  ),
                ),
              ],
              if (hasAction) ...[
                SizedBox(height: compact ? 14 : 24),
                FilledButton.tonalIcon(
                  onPressed: onAction,
                  icon: Icon(actionIcon, size: 18),
                  label: Text(actionLabel!),
                  style: FilledButton.styleFrom(
                    foregroundColor: tint,
                    backgroundColor: tint.withValues(alpha: 0.1),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    textStyle: context.theme.textTheme.labelLarge?.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
