import 'package:pharmo_app/controller/a_controlller.dart';
import 'package:pharmo_app/views/cart/cart_icon.dart';
import 'package:pharmo_app/widgets/others/chevren_back.dart';

class SideAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback? leadingOnTap;
  final IconData? icon;
  final Widget? leading;
  final String? text;
  final Widget? title;
  final bool hasBasket;
  final Widget? action;
  final Color? color;
  final bool? hasRect;
  final bool? centerTitle;
  final PreferredSizeWidget? bottom;
  const SideAppBar({
    super.key,
    this.leadingOnTap,
    this.icon,
    this.leading,
    this.title,
    this.hasBasket = false,
    this.action,
    this.text,
    this.color,
    this.centerTitle,
    this.hasRect = true,
    this.preferredSize = const Size.fromHeight(kToolbarHeight),
    this.bottom,
  });
  @override
  final Size preferredSize;

  @override
  Widget build(BuildContext context) {
    return Consumer2<HomeProvider, CartProvider>(
      builder: (_, home, cart, child) {
        return PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight),
          child: AppBar(
            centerTitle: false,
            title: (text != null)
                ? Text(
                    text!,
                    maxLines: 2,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                : title,
            leading: leading ?? const ChevronBack(),
            actions: [
              if (hasBasket) CartIcon.forAppBar().marginOnly(right: 10),
              action ?? const SizedBox()
            ],
            bottom: bottom,
          ),
        );
      },
    );
  }
}
