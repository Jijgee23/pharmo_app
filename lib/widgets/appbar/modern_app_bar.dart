import 'package:pharmo_app/application/application.dart';

/// Flat app bar in the page's own colour: rounded back and cart buttons in
/// the ModernIcon style, a bold title and an optional subtitle under it.
class ModernAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String? subtitle;
  final bool showCart;
  final List<Widget> actions;

  const ModernAppBar({
    super.key,
    required this.title,
    this.subtitle,
    this.showCart = true,
    this.actions = const [],
  });

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final text = theme.textTheme;
    return AppBar(
      toolbarHeight: 64,
      backgroundColor: theme.scaffoldBackgroundColor,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      automaticallyImplyLeading: false,
      titleSpacing: 16,
      title: Row(
        children: [
          if (Navigator.canPop(context)) ...[
            AppBarButton(
              icon: Icons.arrow_back_ios_new_rounded,
              tooltip: 'Буцах',
              onTap: () => Navigator.maybePop(context),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: text.titleLarge?.copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.2,
                  ),
                ),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: text.bodySmall?.copyWith(color: grey500, height: 1.3),
                  ),
              ],
            ),
          ),
          ...actions,
          if (showCart) ...[
            const SizedBox(width: 8),
            const AppBarCartButton(),
          ],
        ],
      ),
    );
  }
}

/// A rounded white square button, as in [ModernAppBar].
class AppBarButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final String? tooltip;

  const AppBarButton({super.key, required this.icon, required this.onTap, this.tooltip});

  @override
  Widget build(BuildContext context) {
    final button = Material(
      color: white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200, width: 1.2),
      ),
      shadowColor: Colors.black.withValues(alpha: 0.05),
      elevation: 1,
      child: InkWell(
        onTap: onTap,
        customBorder: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: SizedBox(
          width: 42,
          height: 42,
          child: Icon(icon, size: 18, color: Colors.grey.shade800),
        ),
      ),
    );
    return tooltip == null ? button : Tooltip(message: tooltip!, child: button);
  }
}

/// The basket as an [AppBarButton], with a badge only once it holds
/// something.
class AppBarCartButton extends StatelessWidget {
  const AppBarCartButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<CartProvider>(
      builder: (context, cart, _) {
        final count = cart.basket?.totalCount.toInt() ?? 0;
        return Stack(
          clipBehavior: Clip.none,
          children: [
            AppBarButton(
              icon: Icons.shopping_cart_outlined,
              tooltip: 'Сагс',
              onTap: () => goto(const Cart()),
            ),
            if (count > 0)
              Positioned(
                top: -5,
                right: -5,
                child: Container(
                  constraints: const BoxConstraints(minWidth: 20),
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.red.shade500,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: white, width: 1.5),
                  ),
                  child: Text(
                    count > 99 ? '99+' : '$count',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: white,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
