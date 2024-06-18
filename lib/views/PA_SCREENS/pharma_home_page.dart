import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:pharmo_app/controllers/auth_provider.dart';
import 'package:pharmo_app/controllers/home_provider.dart';
import 'package:pharmo_app/views/DM_SCREENS/jagger_dialog.dart';
import 'package:pharmo_app/views/PA_SCREENS/my_orders.dart';
import 'package:pharmo_app/views/PA_SCREENS/tabs/cart.dart';
import 'package:pharmo_app/views/public_uses/filter.dart';
import 'package:pharmo_app/views/PA_SCREENS/tabs/home.dart';
import 'package:pharmo_app/views/public_uses/suppliers/supplier_page.dart';
import 'package:pharmo_app/utilities/colors.dart';
import 'package:pharmo_app/utilities/utils.dart';
import 'package:pharmo_app/widgets/appbar/custom_app_bar.dart';
import 'package:pharmo_app/widgets/drawer_item.dart';
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
  late SharedPreferences prefs;
  bool hidden = false;

  late HomeProvider homeProvider;

  @override
  void initState() {
    init();
    super.initState();
    homeProvider = Provider.of<HomeProvider>(context, listen: false);
    homeProvider.getUserInfo();
    homeProvider.getDeviceInfo();
    homeProvider.getFilters();
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

    final response =
        await http.post(Uri.parse('${dotenv.env['SERVER_URL']}device_id/'),
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
              'Authorization': bearerToken,
            },
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
    FirebaseMessaging _firebaseMessage = FirebaseMessaging.instance;
    String? deviceToken = await _firebaseMessage.getToken();
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
      child: Consumer2<AuthController, HomeProvider>(
        builder: (context, authController, homeProvider, _) {
          return Scaffold(
            drawer: Drawer(
              shape: const RoundedRectangleBorder(),
              width: size.width > 480 ? size.width * 0.5 : size.width * 0.7,
              child: MediaQuery.removePadding(
                removeTop: true,
                context: context,
                child: ListView(
                  children: [
                    CustomDrawerHeader(size: size),
                    DrawerItem(
                      title: 'Миний захиалгууд',
                      icon: Icons.shopping_cart,
                      onTap: () {
                        goto(const MyOrder(), context);
                      },
                    ),
                    DrawerItem(
                      title: 'Нийлүүлэгч',
                      icon: Icons.people,
                      onTap: () {
                        goto(const SupplierPage(), context);
                      },
                    ),
                    DrawerItem(
                      title: 'Гарах',
                      icon: Icons.logout,
                      onTap: () {
                        showLogoutDialog(context);
                      },
                    )
                  ],
                ),
              ),
            ),
            appBar: hidden
                ? null
                : const CustomAppBar(
                    title: 'Нүүр хуудас',
                  ),
            body: NotificationListener<ScrollNotification>(
              onNotification: (scrollNotification) {
                if (scrollNotification is ScrollUpdateNotification &&
                    scrollNotification.scrollDelta! > 0) {
                  setState(() {
                    hidden = true;
                  });
                }
                if (scrollNotification is ScrollUpdateNotification &&
                    scrollNotification.scrollDelta! < 0) {
                  setState(() {
                    hidden = false;
                  });
                }
                if (scrollNotification is ScrollUpdateNotification &&
                    scrollNotification.metrics.atEdge) {
                  setState(() {
                    hidden = false;
                  });
                }
                return true;
              },
              child: _pages[homeProvider.currentIndex],
            ),
            bottomNavigationBar: hidden
                ? null
                : BottomNavigationBar(
                    currentIndex: homeProvider.currentIndex,
                    onTap: homeProvider.changeIndex,
                    items: const [
                      BottomNavigationBarItem(
                        icon: Icon(Icons.home_outlined),
                        activeIcon: Icon(Icons.home),
                        label: 'Нүүр',
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(Icons.category_outlined),
                        activeIcon: Icon(Icons.category),
                        label: 'Ангилал',
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(Icons.shopping_cart_outlined),
                        activeIcon: Icon(Icons.shopping_cart),
                        label: 'Миний сагс',
                      ),
                    ],
                    selectedItemColor: AppColors.primary,
                    unselectedItemColor: AppColors.primary,
                  ),
          );
        },
      ),
    );
  }
}

class CustomDrawerHeader extends StatelessWidget {
  final Size size;
  const CustomDrawerHeader({super.key, required this.size});

  @override
  Widget build(BuildContext context) {
    var style = const TextStyle(color: Colors.white, fontSize: 14);
    return Consumer<HomeProvider>(builder: (context, homeProvider, child) {
      return DrawerHeader(
        decoration: const BoxDecoration(
          color: AppColors.primary,
        ),
        curve: Curves.easeInOut,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Align(
              alignment: Alignment.center,
              child: ClipOval(
                child: Container(
                  decoration: const BoxDecoration(
                      shape: BoxShape.circle, color: Colors.white),
                  child: Icon(
                    Icons.person,
                    color: AppColors.secondary,
                    size: size.width * 0.1,
                  ),
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Имейл хаяг: ${homeProvider.userEmail}',
                  style: style,
                ),
                Text(
                  'Хэрэглэгчийн төрөл: ${homeProvider.userRole == 'S' ? 'Борлуулагч' : 
                      homeProvider.userRole == 'D' ? 'Түгээгч' : 'Эмийн сан'
                    }',
                  style: style,
                ),
              ],
            ),
          ],
        ),
      );
    });
  }
}
