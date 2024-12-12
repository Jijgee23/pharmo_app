import 'package:flutter/material.dart';
import 'package:pharmo_app/controllers/auth_provider.dart';
import 'package:pharmo_app/controllers/home_provider.dart';
import 'package:pharmo_app/utilities/colors.dart';
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
    // final height = size.height;
    return Consumer<HomeProvider>(
      builder: (context, homeProvider, child) => MediaQuery.removePadding(
        context: context,
        removeTop: true,
        child: Drawer(
          backgroundColor: theme.scaffoldBackgroundColor,
          elevation: 0,
          shadowColor: Colors.transparent,
          width: size.width > 480 ? size.width * 0.5 : size.width * 0.8,
          child: Column(
            children: [
              SizedBox(
                height: size.height * 0.075,
              ),
              Container(
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                margin: const EdgeInsets.all(10),
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
                        homeProvider.isDarkMode
                            ? Icons.dark_mode
                            : Icons.light_mode,
                      ),
                    ),
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
    );
  }
}

class DrawerContainer extends StatelessWidget {
  final List<Widget> drawers;
  const DrawerContainer({super.key, required this.drawers});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
          color: theme.cardColor, borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.all(10),
      child: Column(children: drawers),
    );
  }
}

void showLogoutDialog(BuildContext context) {
  Widget button(String text, VoidCallback onPressed) {
    return SizedBox(
      width: 100,
      child: InkWell(
        onTap: onPressed,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
          decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: BorderRadius.circular(15)),
          child: Center(
            child: Text(
              text,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        backgroundColor: AppColors.cleanWhite,
        child: Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  "Системээс гарахдаа итгэлтэй байна уу?",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                    decoration: TextDecoration.none,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    button('Үгүй', () {
                      Navigator.of(context).pop();
                    }),
                    button(
                      'Тийм',
                      () {
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
      );
    },
  );
}
