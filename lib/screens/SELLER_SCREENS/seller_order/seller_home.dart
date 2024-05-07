import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:pharmo_app/controllers/basket_provider.dart';
import 'package:pharmo_app/screens/DM_SCREENS/jagger_dialog.dart';
import 'package:pharmo_app/screens/SELLER_SCREENS/order/history.dart';
import 'package:pharmo_app/screens/SELLER_SCREENS/pharms/pharmacy_list.dart';
import 'package:pharmo_app/screens/SELLER_SCREENS/pharms/resgister_pharm.dart';
import 'package:pharmo_app/screens/SELLER_SCREENS/seller_order/seller_home_tab.dart';
import 'package:pharmo_app/screens/SELLER_SCREENS/seller_shopping_cart/seller_shopping_cart.dart';
import 'package:pharmo_app/utilities/colors.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:badges/badges.dart' as badges;

class SellerHomePage extends StatefulWidget {
  const SellerHomePage({
    super.key,
  });

  @override
  State<SellerHomePage> createState() => _SellerHomePageState();
}

class _SellerHomePageState extends State<SellerHomePage> {
  String email = '';
  String role = '';
  int _selectedIndex = 0;
  int selectedCustomer = 0;
  String? selectedCustomerName;
  List<String> orders = [];
  bool hidden = false;
  ScrollNotification? lastNotification;
  @override
  void initState() {
    getUserInfo();
    super.initState();
  }

  void onTap(index) {
    getSelectedUser();
    setState(() {
      _selectedIndex = index;
    });
  }

  final List _pages = [
    const PharmacyList(),
    const SellerHomeTab(),
    const SellerShoppingCart(),
  ];
  void getUserInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? useremail = prefs.getString('useremail');
    String? userRole = prefs.getString('userrole');
    setState(() {
      email = useremail.toString();
      role = userRole.toString();
    });
  }

  getSelectedUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? customerId = prefs.getInt('pharmId');
    String? customerName = prefs.getString('selectedPharmName');
    setState(() {
      selectedCustomer = customerId!;
      selectedCustomerName = customerName;
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    final basketProvider = Provider.of<BasketProvider>(context);
    return ChangeNotifierProvider(
      create: (context) => BasketProvider(),
      child: SafeArea(
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          appBar: hidden
              ? null
              : AppBar(
                  centerTitle: true,
                  title: selectedCustomer == 0
                      ? const Text('Захиалагч сонгоно уу')
                      : TextButton(
                          onPressed: () {
                            setState(() {
                              _selectedIndex = 0;
                            });
                          },
                          child: RichText(
                            text: TextSpan(
                              text: 'Сонгосон захиалагч: ',
                              style: TextStyle(
                                  color: Colors.blueGrey.shade800,
                                  fontSize: 13.0),
                              children: [
                                TextSpan(
                                    text: '$selectedCustomerName',
                                    style: const TextStyle(
                                        color: AppColors.succesColor,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13.0)),
                              ],
                            ),
                          ),
                        ),
                  actions: [
                    Container(
                      margin: const EdgeInsets.only(right: 15),
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            _selectedIndex = 2;
                          });
                        },
                        child: badges.Badge(
                          badgeContent: Text(
                            "${basketProvider.count}",
                            style: const TextStyle(
                                color: Colors.white, fontSize: 11),
                          ),
                          badgeStyle: const badges.BadgeStyle(
                            badgeColor: Colors.blue,
                          ),
                          child: const Icon(
                            Icons.shopping_cart,
                            color: Colors.red,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
          drawer: Drawer(
            shape: const RoundedRectangleBorder(),
            width: size.height * 0.35,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: size.width,
                  child: DrawerHeader(
                  curve: Curves.easeInOut,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: size.width * 0.1,
                        height: size.width * 0.1,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ),
                        child: Icon(
                          Icons.person,
                          color: AppColors.secondary,
                          size: size.width * 0.1,
                        ),
                      ),
                      Text(
                        'Имейл хаяг: $email',
                        style: TextStyle(
                              color: Colors.white,
                              fontSize: size.height * 0.016),
                      ),
                      Text(
                        'Хэрэглэгчийн төрөл: $role',
                        style: TextStyle(
                              color: Colors.white,
                              fontSize: size.height * 0.016),
                      ),
                    ],
                  ),
                  ),
                ),
                _drawerItem(
                  title: 'Эмийг сан бүртгэх',
                  icon: Icons.medical_services,
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const RegisterPharmPage()));
                  },
                ),
                _drawerItem(
                  title: 'Харилцагчийн захиалгын түүх',
                  icon: Icons.history_outlined,
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) =>
                                const SellerCustomerOrderHisrtory()));
                  },
                ),
                _drawerItem(
                  title: 'Гарах',
                  icon: Icons.logout, 
                  onTap: () {
                    showLogoutDialog(context);
                  },
                ),
              ],
            ),
          ),
          body: NotificationListener<ScrollNotification>(
            onNotification: (scrollNotification) {
              if (scrollNotification is ScrollUpdateNotification &&
                  scrollNotification.scrollDelta! > 0) {
                setState(() {
                  hidden = true;
                });
              } else if (scrollNotification is ScrollUpdateNotification &&
                  scrollNotification.scrollDelta! < 0) {
                setState(() {
                  hidden = false;
                });
              } else if (scrollNotification is ScrollStartNotification) {
                setState(() {
                  hidden = false;
                });
              }
              return true;
            },
            child: _pages[_selectedIndex],
          ),
          bottomNavigationBar: hidden
              ? null
              : BottomNavigationBar(
                  currentIndex: _selectedIndex,
                  selectedItemColor: AppColors.primary,
                  unselectedItemColor: AppColors.primary,
                  onTap: onTap,
                  items: const [
                    BottomNavigationBarItem(
                      icon: Icon(Icons.person_outlined),
                      label: 'Захиалагч',
                      activeIcon: Icon(Icons.person),
                    ),
                    BottomNavigationBarItem(
                        icon: Icon(Icons.home_outlined),
                        label: 'Бараа',
                        activeIcon: Icon(Icons.home)),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.shopping_cart_outlined),
                      label: 'Сагс',
                      activeIcon: Icon(Icons.shopping_cart),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
  Widget _drawerItem(
      {required String title, required IconData icon, Function()? onTap}) {
    return ListTile(
      leading: Icon(icon, color: Colors.lightBlue),
      title: Text(title),
      onTap: onTap,
    );
  }
}
