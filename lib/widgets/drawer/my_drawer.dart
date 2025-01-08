import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pharmo_app/controllers/auth_provider.dart';
import 'package:pharmo_app/controllers/home_provider.dart';
import 'package:pharmo_app/utilities/colors.dart';
import 'package:pharmo_app/utilities/sizes.dart';
import 'package:pharmo_app/widgets/inputs/button.dart';
import 'package:provider/provider.dart';
import '../../utilities/utils.dart';
import '../../views/public_uses/privacy_policy/privacy_policy.dart';
import '../../views/public_uses/user_information/user_information.dart';
import 'drawer_item.dart';

class MyDrawer extends StatelessWidget {
  final List<Widget> drawers;
  const MyDrawer({super.key, required this.drawers});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final theme = Theme.of(context);
    return Consumer<HomeProvider>(
      builder: (context, homeProvider, child) => MediaQuery.removePadding(
        context: context,
        removeTop: true,
        child: Drawer(
          backgroundColor: theme.scaffoldBackgroundColor,
          elevation: 0,
          shadowColor: Colors.transparent,
          width: size.width > 480 ? size.width * 0.5 : size.width * 0.8,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Column(
              children: [
                SizedBox(
                  height: size.height * 0.075,
                ),
                Container(
                  decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(color: theme.shadowColor, blurRadius: 5)
                      ]),
                  margin: const EdgeInsets.only(bottom: 10),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 15, vertical: 30),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
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
                                  Text(
                                    'Сайнуу',
                                    style: theme.textTheme.bodySmall,
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
                                      style: theme.textTheme.bodySmall,
                                    )
                                  : const SizedBox(),
                            ],
                          ),
                        ],
                      ),
                      IconButton(
                        onPressed: () => homeProvider.toggleTheme(),
                        icon: Icon(
                          color: black,
                          homeProvider.isDarkMode
                              ? Icons.dark_mode
                              : Icons.light_mode,
                        ),
                      ),
                    ],
                  ),
                ),
                // drawers,
                Column(
                  children: drawers,
                ),
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
                DrawerItem(
                  title: 'Гарах',
                  asset: 'assets/icons_2/signout.png',
                  onTap: () => logout(context),
                  mainColor: Colors.red,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

void logout(BuildContext context) {
  Get.dialog(
    Dialog(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(20)),
        child: SingleChildScrollView(
          child: Wrap(
            runSpacing: 20,
            children: [
              const Text(
                'Системээс гарах',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const Text('Системээс гарахдаа итгэлтэй байна уу?'),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Button(
                    width: Sizes.width * 0.3,
                    text: 'Үгүй',
                    onTap: () => Navigator.pop(context),
                  ),
                  Button(
                    width: Sizes.width * 0.3,
                    text: 'Тийм',
                    onTap: () {
                      Provider.of<AuthController>(context, listen: false)
                          .logout();
                      Provider.of<AuthController>(context, listen: false)
                          .toggleVisibile();
                      Provider.of<HomeProvider>(context, listen: false)
                          .changeIndex(0);
                    },
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    ),
    barrierDismissible: false,
  );
}
