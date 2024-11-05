import 'package:flutter/material.dart';
import 'package:pharmo_app/controllers/home_provider.dart';
import 'package:provider/provider.dart';
import '../../utilities/utils.dart';
import '../../views/delivery_man/main/logout_dialog.dart';
import '../../views/public_uses/privacy_policy/privacy_policy.dart';
import '../../views/public_uses/user_information/user_information.dart';
import 'drawer_item.dart';

class MyDrawer extends StatelessWidget {
  final List<Widget> drawers;
  const MyDrawer({super.key, required this.drawers});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Consumer<HomeProvider>(
      builder: (context, homeProvider, child) => MediaQuery.removePadding(
        context: context,
        removeTop: true,
        child: Drawer(
          backgroundColor: Colors.white,
          elevation: 10,
          shadowColor: Colors.transparent,
          width: size.width > 480 ? size.width * 0.5 : size.width * 0.8,
          child: SingleChildScrollView(
            child: Column(
              children: [
                // const CustomDrawerHeader(),
                SizedBox(height: size.height * 0.075),
                Container(
                  decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(10)),
                  margin: const EdgeInsets.all(10),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 15, vertical: 30),
                  child: Row(
                    children: [
                      ClipOval(
                        child: Image.asset(
                          'assets/icons/boy.png',
                          height: size.height * 0.054,
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Text(
                                'Сайнуу',
                                style: TextStyle(
                                    fontSize: 12, fontWeight: FontWeight.w700),
                              ),
                              const SizedBox(width: 5),
                              Image.asset(
                                'assets/icons/wave.png',
                                height: 12,
                              ),
                            ],
                          ),
                          homeProvider.userEmail != null
                              ? Text(
                                  homeProvider.userEmail!,
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500),
                                )
                              : const SizedBox()
                        ],
                      )
                    ],
                  ),
                ),
                DrawerContainer(drawers: drawers),
                DrawerContainer(
                  drawers: [
                    DrawerItem(
                      title: 'Миний бүртгэл',
                      asset: 'assets/icons_2/user.png',
                      onTap: () => goto(const UserInformation()),
                    ),
                    DrawerItem(
                      title: 'Нууцлалын бодлого',
                      asset: 'assets/icons_2/privacy.png',
                      onTap: () => goto(const PrivacyPolicy()),
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
