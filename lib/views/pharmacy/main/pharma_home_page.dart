// ignore_for_file: use_build_context_synchronously

import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:pharmo_app/controllers/auth_provider.dart';
import 'package:pharmo_app/controllers/basket_provider.dart';
import 'package:pharmo_app/controllers/home_provider.dart';
import 'package:pharmo_app/controllers/promotion_provider.dart';
import 'package:pharmo_app/utilities/colors.dart';
import 'package:pharmo_app/utilities/constants.dart';
import 'package:pharmo_app/utilities/utils.dart';
import 'package:pharmo_app/views/delivery_man/main/jagger_dialog.dart';
import 'package:pharmo_app/views/pharmacy/drawer_menus/my_orders/my_orders.dart';
import 'package:pharmo_app/views/pharmacy/tabs/cart/cart.dart';
import 'package:pharmo_app/views/pharmacy/tabs/home/home.dart';
import 'package:pharmo_app/views/pharmacy/drawer_menus/promotion/promotion_screen.dart';
import 'package:pharmo_app/views/public_uses/filter/filter.dart';
import 'package:pharmo_app/views/public_uses/privacy_policy/privacy_policy.dart';
import 'package:pharmo_app/views/public_uses/user_information/user_information.dart';
import 'package:pharmo_app/widgets/appbar/custom_app_bar.dart';
import 'package:pharmo_app/widgets/others/drawer_item.dart';
import 'package:provider/provider.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PharmaHomePage extends StatefulWidget {
  const PharmaHomePage({super.key});

  @override
  State<PharmaHomePage> createState() => _PharmaHomePageState();
}

class _PharmaHomePageState extends State<PharmaHomePage> {
  final List _pages = [
    const Home(),
    const FilterPage(),
    const ShoppingCartHome(),
  ];
  bool hidden = false;
  late HomeProvider homeProvider;
  late PromotionProvider promotionProvider;

  @override
  void initState() {
    init();
    super.initState();
    homeProvider = Provider.of<HomeProvider>(context, listen: false);
    promotionProvider = Provider.of<PromotionProvider>(context, listen: false);
    homeProvider.getUserInfo();
    homeProvider.getDeviceInfo();
    homeProvider.getFilters();
    homeProvider.getSuppliers();
    homeProvider.getBranches(context);
  }

  @override
  void dispose() {
    super.dispose();
  }

  init() async {
    String deviceToken = await getDeviceToken();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("access_token");
    String bearerToken = "Bearer $token";
    final response = await http.post(
        Uri.parse('${dotenv.env['SERVER_URL']}device_id/'),
        headers: getHeader(bearerToken),
        body: jsonEncode({"deviceId": deviceToken}));
    if (response.statusCode == 200) {}
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage remoteMessage) {
      String? title = remoteMessage.notification!.title;
      String? description = remoteMessage.notification!.body;
      Alert(
        context: context,
        type: AlertType.info,
        title: title,
        desc: description,
        buttons: [
          DialogButton(
            onPressed: () => Navigator.pop(context),
            width: 120,
            child: const Text(
              "Хаах",
              style: TextStyle(color: Colors.white, fontSize: 15),
            ),
          )
        ],
      ).show();
    });
  }

  Future getDeviceToken() async {
    //request user permission for push notification
    FirebaseMessaging.instance.requestPermission();
    FirebaseMessaging firebaseMessage = FirebaseMessaging.instance;
    String? deviceToken = await firebaseMessage.getToken();
    return (deviceToken == null) ? "" : deviceToken;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthController>(
            create: (context) => AuthController()),
      ],
      child: Consumer3<AuthController, HomeProvider, BasketProvider>(
        builder: (context, authController, homeProvider, basketProvider, _) {
          return Scaffold(
            drawer: Drawer(
              elevation: 0,
              backgroundColor: Colors.white,
              width: size.width > 480 ? size.width * 0.5 : size.width * 0.8,
              child: MediaQuery.removePadding(
                removeTop: true,
                context: context,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const CustomDrawerHeader(),
                      SingleChildScrollView(
                        child: Column(
                          children: [
                            DrawerItem(
                              title: 'Миний захиалгууд',
                              asset: 'assets/icons/order.png',
                              onTap: () => goto(const MyOrder(), context),
                            ),
                            DrawerItem(
                              title: 'Урамшуулал',
                              asset: 'assets/icons/gift.png',
                              onTap: () =>
                                  goto(const PromotionWidget(), context),
                            ),
                            DrawerItem(
                              title: 'Миний бүртгэл',
                              asset: 'assets/icons/user.png',
                              onTap: () =>
                                  goto(const UserInformation(), context),
                            ),
                            DrawerItem(
                              title: 'Нууцлалын бодлого',
                              asset: 'assets/icons/pp.png',
                              onTap: () => goto(const PrivacyPolicy(), context),
                            ),
                            DrawerItem(
                              title: 'Гарах',
                              asset: 'assets/icons/check-out.png',
                              onTap: () {
                                showLogoutDialog(context);
                              },
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
            appBar: hidden
                ? null
                : CustomAppBar(
                    title: Text(
                    'Нүүр хуудас',
                    style: Constants.headerTextStyle,
                  )),
            body: NotificationListener<UserScrollNotification>(
              onNotification: (notification) {
                if (notification.direction == ScrollDirection.reverse) {
                  setState(() => hidden = true);
                } else if (notification.direction == ScrollDirection.forward) {
                  setState(() => hidden = false);
                }
                return true;
              },
              child: _pages[homeProvider.currentIndex],
            ),
            bottomNavigationBar: hidden
                ? null
                : BottomNavigationBar(
                    currentIndex: homeProvider.currentIndex,
                    useLegacyColorScheme: true,
                    type: BottomNavigationBarType.fixed,
                    onTap: homeProvider.changeIndex,
                    showSelectedLabels: true,
                    showUnselectedLabels: false,
                    items: [
                      BottomNavigationBarItem(
                        icon: Image.asset(
                          'assets/icons/house.png',
                          height: 20,
                        ),
                        label: 'Нүүр',
                      ),
                      BottomNavigationBarItem(
                        icon: Image.asset(
                          'assets/icons/options.png',
                          height: 20,
                        ),
                        label: 'Ангилал',
                      ),
                      BottomNavigationBarItem(
                        icon: Image.asset(
                          'assets/icons/shop-tab.png',
                          height: 20,
                        ),
                        label: 'Сагс',
                      ),
                    ],
                  ),
          );
        },
      ),
    );
  }
}

class CustomDrawerHeader extends StatelessWidget {
  const CustomDrawerHeader({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    var style = const TextStyle(color: AppColors.mainDark, fontSize: 14);
    return Consumer<HomeProvider>(builder: (context, homeProvider, child) {
      return Container(
        decoration: const BoxDecoration(
            color: AppColors.cleanWhite,
            border: Border(
              bottom: BorderSide(color: Colors.grey),
            )),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Align(
              alignment: Alignment.center,
              child: ClipOval(
                child: Image.asset(
                  'assets/icons/boy.png',
                  height: 50,
                ),
              ),
            ),
            homeProvider.userEmail != null
                ? Text(
                    homeProvider.userEmail!,
                    style: style,
                  )
                : const SizedBox()
          ],
        ),
      );
    });
  }
}
