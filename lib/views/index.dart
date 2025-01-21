import 'package:flutter/material.dart';
import 'package:pharmo_app/controllers/home_provider.dart';
import 'package:pharmo_app/models/supplier.dart';
import 'package:pharmo_app/utilities/colors.dart';
import 'package:pharmo_app/utilities/sizes.dart';
import 'package:pharmo_app/utilities/utils.dart';
import 'package:pharmo_app/views/delivery_man/index_delivery_man.dart';
import 'package:pharmo_app/views/pharmacy/drawer_menus/my_orders/my_orders.dart';
import 'package:pharmo_app/views/cart/cart.dart';
import 'package:pharmo_app/views/home.dart';
import 'package:pharmo_app/views/pharmacy/drawer_menus/promotion/promotion_screen.dart';
import 'package:pharmo_app/views/seller/customers.dart';
import 'package:pharmo_app/views/seller/drawer_menus/order/seller_orders.dart';
import 'package:pharmo_app/views/seller/seller_report/seller_report.dart';
import 'package:pharmo_app/widgets/appbar/custom_app_bar.dart';
import 'package:pharmo_app/widgets/bottom_bar/bottom_bar.dart';
import 'package:pharmo_app/widgets/drawer/drawer_item.dart';
import 'package:pharmo_app/widgets/drawer/my_drawer.dart';
import 'package:provider/provider.dart';

class IndexPharma extends StatefulWidget {
  const IndexPharma({super.key});

  @override
  State<IndexPharma> createState() => _IndexPharmaState();
}

class _IndexPharmaState extends State<IndexPharma> {
  late HomeProvider homeProvider;

  @override
  void initState() {
    super.initState();
    homeProvider = Provider.of<HomeProvider>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeProvider>(
      builder: (context, homeProvider, _) {
        bool isPharma = homeProvider.userRole == 'PA';
        return Scaffold(
          extendBody: true,
          drawer: MyDrawer(
              drawers: isPharma ? pharmaDrawerItems() : sellerDrawerItems()),
          appBar: CustomAppBar(
              title: isPharma ? pharmAppBarTitle() : sellerAppBarTitle()),
          body: Container(
            padding: const EdgeInsets.only(right: 10, left: 10),
            child: isPharma
                ? _pharmacyPages[homeProvider.currentIndex]
                : _sellerPages[homeProvider.currentIndex],
          ),
          bottomNavigationBar: BottomBar(
            labels: isPharma ? pharmaLabels : sellerLabels,
            icons: isPharma ? pharmaIcons : sellericons,
          ),
        );
      },
    );
  }

  pharmAppBarTitle() {
    if (homeProvider.currentIndex == 0) {
      return searchBar(homeProvider);
    } else {
      return const Text(
        'Сагс',
        style: TextStyle(
          color: white,
          fontWeight: FontWeight.bold,
          fontSize: 13.0,
        ),
      );
    }
  }

  sellerAppBarTitle() {
    if (homeProvider.currentIndex == 1) {
      return searchBar(homeProvider);
    } else {
      return getSellerAppBarTitle();
    }
  }

  searchBar(HomeProvider homeProvider) {
    return Row(
      children: [
        Expanded(
          flex: 7,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            decoration: BoxDecoration(
                color: white, borderRadius: BorderRadius.circular(30)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (homeProvider.userRole == 'PA') suplierPicker(),
                const SizedBox(width: 10),
                Expanded(
                    child: TextFormField(
                  cursorHeight: Sizes.smallFontSize + 2,
                  style: const TextStyle(fontSize: Sizes.mediumFontSize),
                  decoration: InputDecoration(
                    hintText: '${homeProvider.searchType} хайх',
                    hintStyle: const TextStyle(
                        fontSize: Sizes.mediumFontSize - 2,
                        color: Colors.black),
                    border: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  ),
                  onChanged: (v) => _onfieldChanged(v),
                  onFieldSubmitted: (v) => _onFieldSubmitted(v),
                )),
                InkWell(
                    onTap: () => _changeSearchType(),
                    child: const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: black,
                    )),
                const SizedBox(width: 5),
                viewMode()
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget suplierPicker() {
    return IntrinsicWidth(
      child: InkWell(
        onTap: () => _onPickSupplier(context),
        child: Text(
          '${homeProvider.supName} :',
          style: const TextStyle(
            fontSize: Sizes.mediumFontSize - 2,
            color: AppColors.succesColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget viewMode() {
    return InkWell(
      onTap: () => homeProvider.switchView(),
      child: Icon(
        homeProvider.isList ? Icons.grid_view : Icons.list_sharp,
        color: black,
      ),
    );
  }

  // FOR PARMACY
  List<String> pharmaIcons = ['category', 'cart'];
  List<String> pharmaLabels = ['Бараа', 'Сагс'];
  pharmaDrawerItems() {
    return [
      DrawerItem(
        title: 'Захиалгууд',
        asset: 'assets/icons_2/time-past.png',
        onTap: () => goto(const MyOrder()),
      ),
      DrawerItem(
        title: 'Урамшуулал',
        asset: 'assets/icons_2/gift-box-benefits.png',
        onTap: () => goto(const PromotionWidget()),
      ),
    ];
  }

  final List _pharmacyPages = [
    const Home(),
    const Cart(),
  ];

  // FOR SELLER
  List<String> sellericons = ['user', 'category', 'cart'];
  List<String> sellerLabels = ['Харилцагч', 'Бараа', 'Сагс'];
  sellerDrawerItems() {
    return [
      // DrawerItem(
      //     title: 'Эмийг сан бүртгэх',
      //     onTap: () => goto(const RegisterPharmPage()),
      //     asset: 'assets/icons_2/doctor.png'),

      DrawerItem(
          title: 'Захиалгууд',
          onTap: () => goto(
                const SellerOrders(),
              ),
          asset: 'assets/icons_2/time-past.png'),
      // DrawerItem(
      //     title: 'Орлогын жагсаалт',
      //     onTap: () => goto(const IncomeList()),
      //     asset: 'assets/icons_2/wallet-income.png'),
      DrawerItem(
          title: 'Тайлан',
          onTap: () => goto(const SellerReportPage()),
          asset: 'assets/icons_2/wallet-income.png'),
      homeProvider.userRole == 'D'
          ? DrawerItem(
              title: 'Түгээгчрүү шилжих',
              onTap: () {
                homeProvider.changeIndex(0);
                gotoRemoveUntil(const IndexDeliveryMan());
              },
              asset: 'assets/icons_2/swap.png',
            )
          : const SizedBox(),
    ];
  }

  Widget getSellerAppBarTitle() {
    const textStyle = TextStyle(
      color: white,
      fontSize: 12.0,
      letterSpacing: 0.3,
      fontWeight: FontWeight.bold,
    );
    return homeProvider.selectedCustomerId == 0
        ? const Text('Харилцагч сонгоно уу!', style: textStyle)
        : TextButton(
            onPressed: () => homeProvider.changeIndex(0),
            child: RichText(
              text: TextSpan(
                text: 'Сонгосон харилцагч: ',
                style: textStyle,
                children: [
                  TextSpan(
                    text: homeProvider.selectedCustomerName,
                    style: const TextStyle(
                      color: white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13.0,
                    ),
                  ),
                ],
              ),
            ),
          );
  }

  final List _sellerPages = [
    const CustomerList(),
    const Home(),
    const Cart(),
  ];
  _changeSearchType() {
    showMenu(
      surfaceTintColor: Colors.white,
      color: Colors.white,
      context: context,
      position: const RelativeRect.fromLTRB(150, 120, 0, 0),
      items: homeProvider.stype
          .map(
            (e) => PopupMenuItem(
              onTap: () {
                homeProvider.setQueryTypeName(e);
                int index = homeProvider.stype.indexOf(e);
                if (index == 0) {
                  homeProvider.setQueryType('name');
                } else if (index == 1) {
                  homeProvider.setQueryType('barcode');
                }
              },
              child: Text(
                e,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  fontSize: Sizes.smallFontSize,
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  // Хайлт функц
  _onfieldChanged(String v) async {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (v.isEmpty || v == '') {
        homeProvider.setPageKey(1);
        homeProvider.fetchProducts();
      } else {
        homeProvider.filterProduct(v);
      }
    });
  }

  _onFieldSubmitted(String v) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (v.isEmpty || v == '') {
        homeProvider.setPageKey(1);
        homeProvider.fetchProducts();
      } else {
        homeProvider.filterProduct(v);
      }
    });
  }

  _onPickSupplier(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    showMenu(
      surfaceTintColor: Colors.white,
      color: Colors.white,
      context: context,
      position: RelativeRect.fromLTRB(
          size.width * 0.02, size.height * 0.15, size.width * 0.8, 0),
      elevation: 12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      items: homeProvider.supList
          .map(
            (e) => PopupMenuItem(
              onTap: () async => await onPickSupp(e),
              child: Text(
                e.name,
                style: TextStyle(
                  color: e.name == homeProvider.supName
                      ? AppColors.succesColor
                      : Theme.of(context).primaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  onPickSupp(Supplier e) async {
    await homeProvider.pickSupplier(int.parse(e.id), context);
    await homeProvider.changeSupName(e.name);
    homeProvider.setSupId(int.parse(e.id));
    // basketProvider.getBasket();
    homeProvider.clearItems();
    homeProvider.setPageKey(1);
    homeProvider.fetchProducts();
    // await promotionProvider.getMarkedPromotion();
    // homeProvider.refresh(context, homeProvider, promotionProvider);
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   if (promotionProvider.markedPromotions.isNotEmpty) {
    //     homeProvider.showMarkedPromos(context, promotionProvider);
    //   }
    // });
    // Navigator.pop(context);
  }
}
