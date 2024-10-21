import 'package:flutter/material.dart';
import '../../utilities/utils.dart';
import '../../views/delivery_man/main/logout_dialog.dart';
import '../../views/pharmacy/main/pharma_home_page.dart';
import '../../views/public_uses/privacy_policy/privacy_policy.dart';
import '../../views/public_uses/user_information/user_information.dart';
import 'drawer_header.dart';
import 'drawer_item.dart';

class MyDrawer extends StatelessWidget {
  final List<Widget> drawers;
  const MyDrawer({super.key, required this.drawers});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return MediaQuery.removePadding(
      context: context,
      removeTop: true,
      child: Drawer(
        backgroundColor: Colors.white,
        elevation: 0,
        width: size.width > 480 ? size.width * 0.5 : size.width * 0.8,
        child: SingleChildScrollView(
          child: Column(
            children: [
              const CustomDrawerHeader(),
              DrawerContainer(drawers: drawers),
              DrawerContainer(
                drawers: [
                  DrawerItem(
                    title: 'Миний бүртгэл',
                    asset: 'assets/icons_2/user.png',
                    onTap: () => goto(const UserInformation(), context),
                  ),
                  DrawerItem(
                    title: 'Нууцлалын бодлого',
                    asset: 'assets/icons_2/privacy.png',
                    onTap: () => goto(const PrivacyPolicy(), context),
                  ),
                ],
              ),
              DrawerContainer(
                drawers: [
                  DrawerItem(
                    title: 'Гарах',
                    asset: 'assets/icons_2/signout.png',
                    onTap: () {
                      showLogoutDialog(context);
                    },
                    mainColor: Colors.red,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
class DrawerContainer extends StatelessWidget {
  final List<Widget> drawers;
  const DrawerContainer({super.key, required this.drawers});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: Colors.grey.shade200, borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.all(10),
      child: Column(children: drawers),
    );
  }
}