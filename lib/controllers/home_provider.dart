// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:pharmo_app/controllers/auth_provider.dart';
import 'package:pharmo_app/controllers/basket_provider.dart';
import 'package:pharmo_app/controllers/promotion_provider.dart';
import 'package:pharmo_app/models/branch.dart';
import 'package:pharmo_app/models/category.dart';
import 'package:pharmo_app/models/marked_promo.dart';
import 'package:pharmo_app/models/products.dart';
import 'package:pharmo_app/models/sector.dart';
import 'package:pharmo_app/models/supplier.dart';
import 'package:pharmo_app/utilities/colors.dart';
import 'package:pharmo_app/utilities/constants.dart';
import 'package:pharmo_app/utilities/utils.dart';
import 'package:pharmo_app/views/public_uses/shopping_cart/order_done.dart';
import 'package:pharmo_app/widgets/dialog_and_messages/snack_message.dart';
import 'package:pharmo_app/widgets/inputs/custom_button.dart';
import 'package:pharmo_app/widgets/inputs/custom_text_filed.dart';
import 'package:pharmo_app/widgets/ui_help/box.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeProvider extends ChangeNotifier {
  final TextEditingController _searchController = TextEditingController();
  TextEditingController get searchController => _searchController;
  final PageController _pageController = PageController();
  PageController get pageController => _pageController;
  List<String> stype = ['Нэрээр', 'Баркодоор', 'Ерөнхий нэршлээр'];
  String queryType = 'name';
  String searchType = 'Нэрээр';
  bool isList = false;
  String query = '';
  bool searching = false;
  // final int page = 1;
  final int pageSize = 20;
  int currentIndex = 0;
  bool invisible = false;
  String selectedCustomerName = '';
  int selectedCustomerId = 0;
  String? userEmail;
  String? userRole;
  int userId = 0;
  int? basketId;
  int selectedBranchId = -1;
  String payType = 'NOW';

  String? note;
  List<Branch> branchList = <Branch>[];
  late LocationPermission permission;
  late bool servicePermission = false;
  Position? _currentLocation;
  double? currentLatitude;
  double? currentLongitude;
  String? cName;
  String? cRd;
  String? email;
  String? phone;
  String? detail;
  List<Category> categories = <Category>[];
  List<Manufacturer> mnfrs = <Manufacturer>[];
  List<Manufacturer> vndrs = <Manufacturer>[];
  late Map<String, dynamic> _userInfo;
  Map<String, dynamic> get userInfo => _userInfo;
  final List<Supplier> _supList = <Supplier>[];
  List<Supplier> get supList => _supList;
  String _supName = 'Нийлүүлэгч сонгох';
  String get supName => _supName;
  List<Sector> branches = <Sector>[];
  String demo = 'demo';

  void changeDemo(String d) {
    demo = d;
    notifyListeners();
  }

  void refresh(BuildContext context, HomeProvider homeProvider,
      PromotionProvider promotionProvider) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (PromotionProvider().markedPromotions.isNotEmpty) {
        showMarkedPromos(context, promotionProvider);
      }
    });
  }

  // Барааний жагсаалт & бараа хайх
  getProducts(int pageKey) async {
    try {
      final response = await apiGet(!searching
          ? 'products/?page=$pageKey&page_size=$pageSize'
          : 'products/search/?k=$queryType&v=$query');
      if (response.statusCode == 200) {
        if (!searching) {
          Map res = jsonDecode(utf8.decode(response.bodyBytes));
          List<Product> prods = (res['results'] as List)
              .map((data) => Product.fromJson(data))
              .toList();
          return prods;
        } else {
          final res = jsonDecode(utf8.decode(response.bodyBytes));
          List<Product> prods =
              (res as List).map((data) => Product.fromJson(data)).toList();
          return prods;
        }
      }
    } catch (e) {
      debugPrint('error============= on getProduct> ${e.toString()}');
    }
  }

  getBranches(BuildContext context) async {
    try {
      final response = await apiGet('branch');
      if (response.statusCode == 200) {
        List<dynamic> res = jsonDecode(utf8.decode(response.bodyBytes));
        branches = (res).map((data) => Sector.fromJson(data)).toList();
        notifyListeners();
      } else {
        message(message: 'Түр хүлээгээд дахин оролдоно уу!', context: context);
      }
    } catch (e) {
      message(
          message: 'Өгөгдөл авчрах үед алдаа гарлаа. Админтай холбогдоно уу!',
          context: context);
    }
  }

  // хямдралтай, эрэлттэй, шинэ бараа
  filterProducts(String filter) async {
    try {
      final response = await apiGet('products/?$filter');
      if (response.statusCode == 200) {
        Map res = jsonDecode(utf8.decode(response.bodyBytes));
        List<Product> prods = (res['results'] as List)
            .map((data) => Product.fromJson(data))
            .toList();
        notifyListeners();
        return prods;
      }
    } catch (e) {
      debugPrint('error============= on filterProduct > ${e.toString()}');
    }
  }

  // Онцлох урамшуулал харуулах
  showMarkedPromos(BuildContext context, PromotionProvider promotionProvider) {
    final pageController = PageController();
    Get.dialog(
      Container(
        margin: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(
            Radius.circular(20),
          ),
        ),
        height: double.infinity,
        child: Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            leadingWidth: double.infinity,
            leading: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                    onTap: () => pageController.previousPage(
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.linear),
                    child: const Text(
                      'Өмнөх',
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                  promotionProvider.markedPromotions.isEmpty
                      ? const SizedBox()
                      : InkWell(
                          onTap: () {
                            if (pageController.page ==
                                promotionProvider.markedPromotions.length - 1) {
                              Navigator.pop(context);
                            } else {
                              pageController.nextPage(
                                duration: const Duration(milliseconds: 500),
                                curve: Curves.linear,
                              );
                            }
                          },
                          child: const Text(
                            'Дараах',
                            style: TextStyle(fontSize: 14),
                          ),
                        ),
                ],
              ),
            ),
          ),
          body: Column(
            children: [
              Expanded(
                child: PageView(
                  controller: pageController,
                  scrollDirection: Axis.horizontal,
                  children: [
                    ...promotionProvider.markedPromotions.map(
                      (p) => (p.promoType == 2)
                          ? MakredPromoOnDialog(promo: p)
                          : BuyingPromoOnDialog(
                              promo: p,
                            ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Ангилалийн жагсаалт авах
  getFilters() async {
    try {
      final response = await apiGet('product/filters/');
      if (response.statusCode == 200) {
        Map res = jsonDecode(utf8.decode(response.bodyBytes));
        categories =
            (res['cats'] as List).map((e) => Category.fromJson(e)).toList();

        mnfrs = (res['mnfrs'] as List)
            .map((e) => Manufacturer.fromJson(e))
            .toList();
        vndrs = (res['vndrs'] as List)
            .map((e) => Manufacturer.fromJson(e))
            .toList();
        notifyListeners();
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

// Бараа ангиллаар шүүх
  filter(String type, int filters, int page, int pageSize) async {
    try {
      final response = await apiGet(
          'products/?$type=[$filters]&page=$page&page_size=$pageSize');
      if (response.statusCode == 200) {
        Map res = jsonDecode(utf8.decode(response.bodyBytes));
        List<Product> prods = (res['results'] as List)
            .map((data) => Product.fromJson(data))
            .toList();
        return prods;
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  filterCate(int id, int page, int pageSize) async {
    try {
      final response = await apiGet(
          'products/?category=[$id]&page=$page&page_size=$pageSize');
      if (response.statusCode == 200) {
        Map<String, dynamic> res = jsonDecode(utf8.decode(response.bodyBytes));
        List<Product> prods = (res['results'] as List)
            .map((data) => Product.fromJson(data))
            .toList();
        return prods;
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  // Нийлүүлэгчдийн жагсаалт авах
  getSuppliers() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      int? id = prefs.getInt('suppID');
      final response = await apiGet('suppliers');
      if (response.statusCode == 200) {
        Map res = jsonDecode(utf8.decode(response.bodyBytes));
        _supList.clear();
        res.forEach((key, value) {
          var model = Supplier(key, value);
          if (id != null && int.parse(model.id) == id) {
            changeSupName(model.name);
          }
          _supList.add(model);
        });
        notifyListeners();
      } else {
        debugPrint('Түр хүлээгээд дахин оролдоно уу!');
      }
    } catch (e) {
      debugPrint('SERVER ERROR: $e');
    }
  }

  // Нийлүүлэгч сонгох
  pickSupplier(int supId, BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final response = await apiPost('pick/', jsonEncode({'supplierId': supId}));
    if (response.statusCode == 200) {
      Map<String, dynamic> res = jsonDecode(response.body);
      await prefs.setString('access_token', res['access_token']);
      await prefs.setString('refresh_token', res['refresh_token']);
      await prefs.setInt('picked_suplier', res['id']);
      await PromotionProvider().getMarkedPromotion();
      await getFilters();
      BasketProvider().getBasket();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (PromotionProvider().markedPromotions.isNotEmpty) {
          showMarkedPromos(context, PromotionProvider());
        }
      });
      notifyListeners();
    } else if (response.statusCode == 403) {
      debugPrint('PERMISSION DENIED');
    } else {
      debugPrint('SERVER ERROR');
    }
  }

  getUserInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? useremail = prefs.getString('useremail');
    String? userrole = prefs.getString('userrole');
    int? uid = prefs.getInt('user_id');
    userEmail = useremail.toString();
    userRole = userrole.toString();
    userId = int.parse(uid.toString());
    notifyListeners();
  }

  getSelectedUser(int customerId, String customerName) {
    selectedCustomerId = customerId;
    selectedCustomerName = customerName;
    notifyListeners();
  }

  // Сагсны id авах
  getBasketId() async {
    final response = await apiGet('get_basket/');
    final res = jsonDecode(utf8.decode(response.bodyBytes));
    if (response.statusCode == 200) {
      basketId = res['id'];
    }
    notifyListeners();
  }

  getCustomerBranch() async {
    try {
      final response = await apiPost('seller/customer_branch/',
          jsonEncode({'customerId': selectedCustomerId}));
      branchList.clear();
      if (response.statusCode == 200) {
        List<dynamic> res = jsonDecode(utf8.decode(response.bodyBytes));
        for (int i = 0; i < res.length; i++) {
          branchList.add(Branch.fromJson(res[i]));
        }
        selectedBranchId = res[0]['id'];
        notifyListeners();
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future getPosition() async {
    _currentLocation = await _getCurrentLocation();
    currentLatitude =
        double.parse(_currentLocation!.latitude.toStringAsFixed(6));
    currentLongitude =
        double.parse(_currentLocation!.longitude.toStringAsFixed(6));
  }

  Future<Position> _getCurrentLocation() async {
    servicePermission = await Geolocator.isLocationServiceEnabled();

    if (!servicePermission) {}
    permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    return await Geolocator.getCurrentPosition();
  }

  searchByLocation(BuildContext context) async {
    try {
      Object body = jsonEncode({
        'lat': currentLatitude,
        'lng': currentLongitude,
      });
      final response = await apiPost('seller/search_by_location/', body);
      if (response.statusCode == 200) {
        if (jsonDecode(utf8.decode(response.bodyBytes).toString()) ==
            'not found') {
          message(message: 'Харилцагч олдсонгүй', context: context);
        } else {
          Map<String, dynamic> res =
              jsonDecode(utf8.decode(response.bodyBytes));
          message(
              context: context,
              message:
                  '${res['company']['name']} харилцагчийн ${res['name']} олдлоо');
          if (res['manager']['id'] == null) {
            selectedCustomerId = res['director']['id'];
            selectedCustomerName = res['company']['name'];
            getSelectedUser(selectedCustomerId, selectedCustomerName);
            changeIndex(1);
          } else {
            selectedCustomerId = res['manager']['id'];
            selectedCustomerName = res['company']['name'];
            getSelectedUser(selectedCustomerId, selectedCustomerName);
            changeIndex(1);
          }
        }
      } else {
        message(message: 'Серверийн алдаа', context: context);
      }
    } catch (e) {
      message(message: 'Интернет холболтоо шалгана уу!.', context: context);
    }
  }

  deactiveUser(String password, BuildContext context) async {
    try {
      final response = await apiPatch('auth/delete_user_account/', jsonEncode({'pwd': password}));
      if (response.statusCode == 200) {
        AuthController().logout(context);
        message(
            message: '$userEmail и-мейл хаягтай таний бүртгэл устгагдлаа',
            context: context);
      } else {
        message(message: 'Алдаа гарлаа', context: context);
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  createSellerOrder(BuildContext context, String type) async {
    try {
      Object body = jsonEncode(
        {
          'customer_id': selectedCustomerId,
          'basket_id': basketId,
          'payType': type,
          "note": (note != null) ? note : null
        },
      );
      final response = await apiPost('seller/order/', body);
      final basketProvider =
          Provider.of<BasketProvider>(context, listen: false);
      if (response.statusCode == 201) {
        final res = jsonDecode(utf8.decode(response.bodyBytes));
        final orderNumber = res['orderNo'];
        goto(OrderDone(orderNo: orderNumber.toString()));
        await basketProvider.clearBasket(basket_id: basketId!);
        note = null;
        notifyListeners();
      } else {
        message(message: 'Алдаа гарлаа', context: context);
      }
    } catch (e) {
      message(message: 'Захиалга үүсгэхэд алдаа гарлаа.', context: context);
    }
  }

  setNote(String nv) {
    note = nv;
    notifyListeners();
  }

  setQueryType(String type) {
    queryType = type;
    notifyListeners();
  }

  setPayType(String v) {
    payType = v;
    notifyListeners();
  }

  setQueryTypeName(String newValue) {
    searchType = newValue;
    notifyListeners();
  }

  changeQueryValue(String? value) {
    query = value ?? '';
    notifyListeners();
  }

  changeSearching(bool a) {
    searching = a;
    notifyListeners();
  }

  changeSupName(String name) async {
    _supName = name;
    notifyListeners();
  }

  changeIndex(int index) {
    currentIndex = index;
    notifyListeners();
  }

  changeSelectedCustomerId(int customerId) {
    selectedCustomerId = customerId;
    notifyListeners();
  }

  changeSelectedCustomerName(String customerName) {
    selectedCustomerName = customerName;
    notifyListeners();
  }

  toggleInvisible() {
    invisible = !invisible;
    notifyListeners();
  }

  switchView() {
    isList = !isList;
    notifyListeners();
  }
}

class MakredPromoOnDialog extends StatelessWidget {
  final MarkedPromo promo;
  const MakredPromoOnDialog({super.key, required this.promo});

  @override
  Widget build(BuildContext context) {
    var textStyle = TextStyle(
        fontSize: 16, fontWeight: FontWeight.bold, color: Colors.red.shade600);
    return Container(
      padding: const EdgeInsets.all(20),
      child: SingleChildScrollView(
        child: Column(
          children: [
            (promo.desc != null)
                ? Box(
                    child: Container(
                    width: double.infinity,
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    child: Text(promo.desc!),
                  ))
                : const SizedBox(),
            Box(
              child: Wrap(
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                direction: Axis.horizontal,
                children: [
                  const Text('Захиалгын дүн '),
                  Text(
                    '${promo.total}₮ ',
                    style: TextStyle(fontSize: 20, color: Colors.red.shade600),
                  ),
                  const Text('-с дээш бол '),
                  Text(
                    '${promo.procent}% ',
                    style: TextStyle(fontSize: 20, color: Colors.red.shade600),
                  ),
                  const Text('хямдрал '),
                  promo.gift != null
                      ? const Text('эдэлж')
                      : const Text('эдлээрэй!')
                ],
              ),
            ),
            (promo.gift != null)
                ? const Icon(Icons.add, color: AppColors.secondary, size: 30)
                : const SizedBox(),
            (promo.gift != null)
                ? Box(
                    child: Column(
                      children: [
                        (promo.gift != null)
                            ? GridView.builder(
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  mainAxisSpacing: 20,
                                  crossAxisSpacing: 20,
                                ),
                                shrinkWrap: true,
                                physics: const AlwaysScrollableScrollPhysics(),
                                itemBuilder: (context, index) {
                                  return product(promo.gift?[index], noImage);
                                },
                                itemCount: promo.gift?.length,
                              )
                            : const SizedBox(),
                        const SizedBox(height: 15),
                        const Text('бэлгэнд аваарай!')
                      ],
                    ),
                  )
                : const SizedBox(),
            promo.endDate != null
                ? Box(
                    child: Column(
                      children: [
                        const Text('Урамшуулал дуусах хугацаа:'),
                        Text(
                          promo.endDate != null
                              ? promo.endDate!.substring(0, 10)
                              : '-',
                          style: textStyle,
                        )
                      ],
                    ),
                  )
                : const SizedBox(),
          ],
        ),
      ),
    );
  }
}

class BuyingPromoOnDialog extends StatefulWidget {
  final MarkedPromo promo;
  const BuyingPromoOnDialog({super.key, required this.promo});

  @override
  State<BuyingPromoOnDialog> createState() => _BuyingPromoOnDialogState();
}

class _BuyingPromoOnDialogState extends State<BuyingPromoOnDialog> {
  int selectedBranch = 0;
  final TextEditingController note = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final promo = widget.promo;
    var textStyle = TextStyle(
        fontSize: 16, fontWeight: FontWeight.bold, color: Colors.red.shade600);
    var box = const SizedBox(height: 10);
    return Consumer2<PromotionProvider, HomeProvider>(
      builder: (context, promotionProvider, home, child) => Scaffold(
        body: Container(
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                      onPressed: () =>
                          promotionProvider.hidePromo(promo.id!, context),
                      child: const Text('Дахиж харахгүй')),
                ),
                Text(
                  promo.name!,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, letterSpacing: .7),
                ),
                (promo.desc != null)
                    ? Box(
                        child: Text(promo.desc!),
                      )
                    : const SizedBox(),
                promo.bundles != null
                    ? Box(
                        child: Column(
                          children: [
                            const Text('Багц:',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 10),
                            promo.bundles != null
                                ? GridView.builder(
                                    gridDelegate:
                                        const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2,
                                      mainAxisSpacing: 10,
                                      crossAxisSpacing: 10,
                                    ),
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    itemBuilder: (context, index) {
                                      return product(
                                          promo.bundles?[index], noImage);
                                    },
                                    itemCount: promo.bundles?.length,
                                  )
                                : const SizedBox(),
                          ],
                        ),
                      )
                    : const SizedBox(),
                (promo.bundlePrice != null)
                    ? Box(
                        child: Column(
                          children: [
                            const Text('Багцийн үнэ:',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            Text(
                                promo.bundlePrice != null
                                    ? promo.bundlePrice.toString()
                                    : '-',
                                style: textStyle),
                            box,
                          ],
                        ),
                      )
                    : const SizedBox(),
                (promo.gift != null)
                    ? Box(
                        child: Column(
                          children: [
                            Icon(Icons.add,
                                color: Colors.grey.shade900, size: 30),
                            box,
                            const Text('Бэлэг:',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            box,
                            GridView.builder(
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                mainAxisSpacing: 10,
                                crossAxisSpacing: 10,
                              ),
                              shrinkWrap: true,
                              physics: const AlwaysScrollableScrollPhysics(),
                              itemBuilder: (context, index) {
                                return product(promo.gift?[index], noImage);
                              },
                              itemCount: promo.gift?.length,
                            )
                          ],
                        ),
                      )
                    : const SizedBox(),
                promo.endDate != null
                    ? Box(
                        child: Column(
                          children: [
                            box,
                            const Text('Урамшуулал дуусах хугацаа:'),
                            Text(promo.endDate!.substring(0, 10),
                                style: textStyle),
                          ],
                        ),
                      )
                    : const SizedBox(),
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 5),
                  child: CustomButton(
                    ontap: () => promotionProvider.setOrderStarted(),
                    text:
                        promotionProvider.orderStarted ? 'Цуцлах' : 'Захиалах',
                  ),
                ),
                (promotionProvider.orderStarted == false)
                    ? const SizedBox()
                    : Column(
                        children: [
                          Box(
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text('Нийт тоо, ширхэг:'),
                                    Text(solveQTY().toString()),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text('Үнийн дүн:'),
                                    Text(
                                        '${promotionProvider.promoDetail.bundlePrice.toString()}₮'),
                                  ],
                                )
                              ],
                            ),
                          ),
                          box,
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Container(
                                  margin: const EdgeInsets.only(right: 5),
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 10, horizontal: 20),
                                  decoration: BoxDecoration(
                                    color: promotionProvider.delivery
                                        ? Colors.grey.shade300
                                        : AppColors.primary,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: InkWell(
                                    onTap: () =>
                                        promotionProvider.setDelivery(false),
                                    child: const Center(
                                        child: Text('Хүргэлтээр')),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Container(
                                  margin: const EdgeInsets.only(left: 5),
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 10, horizontal: 20),
                                  decoration: BoxDecoration(
                                    color: !promotionProvider.delivery
                                        ? Colors.grey.shade300
                                        : AppColors.primary,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: InkWell(
                                    onTap: () =>
                                        promotionProvider.setDelivery(true),
                                    child:
                                        const Center(child: Text('Очиж авах')),
                                  ),
                                ),
                              )
                            ],
                          ),
                          box,
                          promotionProvider.delivery
                              ? const SizedBox()
                              : Box(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: home.branches
                                        .map((e) => branch(e))
                                        .toList(),
                                  ),
                                ),
                          box,
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Expanded(
                                child: Container(
                                  margin: const EdgeInsets.only(right: 5),
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 10, horizontal: 20),
                                  decoration: BoxDecoration(
                                    color: !promotionProvider.isCash
                                        ? Colors.grey.shade300
                                        : AppColors.primary,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: InkWell(
                                    onTap: () {
                                      promotionProvider.setPayType();
                                      promotionProvider.setIsCash(true);
                                    },
                                    child: const Center(
                                        child: Text('Бэлнээр')),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Container(
                                  margin: const EdgeInsets.only(left: 5),
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 10, horizontal: 20),
                                  decoration: BoxDecoration(
                                    color: promotionProvider.isCash
                                        ? Colors.grey.shade300
                                        : AppColors.primary,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: InkWell(
                                    onTap: () {
                                      promotionProvider.setPayType();
                                      promotionProvider.setIsCash(false);
                                    },
                                    child: const Center(child: Text('Зээлээр')),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          box,
                          InkWell(
                              borderRadius: BorderRadius.circular(10),
                              splashColor: Colors.blue.shade100,
                              onTap: () => promotionProvider
                                  .setHasnote(!promotionProvider.hasNote),
                              child: const Text('Нэмэлт тайлбар',
                                  style: TextStyle(color: AppColors.primary))),
                          box,
                          !promotionProvider.hasNote
                              ? const SizedBox()
                              : CustomTextField(
                                  hintText: 'Тайлбар', controller: note),
                          box,
                          Container(
                            margin: const EdgeInsets.symmetric(vertical: 5),
                            child: CustomButton(
                              ontap: () {
                                promotionProvider.orderPromo(widget.promo.id!,
                                    selectedBranch, note.text, context);
                              },
                              text: 'Баталгаажуулах',
                            ),
                          ),
                          box,
                          !promotionProvider.showQr
                              ? const SizedBox()
                              : Column(
                                  children: [
                                    const Text(
                                      'Дараах QR кодыг уншуулж төлбөр төлснөөр захиалга баталгаажна',
                                      textAlign: TextAlign.center,
                                    ),
                                    Center(
                                        child: QrImageView(
                                      data: promotionProvider.qrData.qrTxt!,
                                      size: 250,
                                    )),
                                    InkWell(
                                        borderRadius: BorderRadius.circular(10),
                                        splashColor: Colors.blue.shade100,
                                        onTap: () => promotionProvider.setBank(
                                            !promotionProvider.useBank),
                                        child: const Text(
                                          'Банкны аппаар төлөх',
                                          style:
                                              TextStyle(color: AppColors.main),
                                        )),
                                    !promotionProvider.useBank
                                        ? const SizedBox()
                                        : SizedBox(
                                            width: double.infinity,
                                            child: Scrollbar(
                                              thickness: 1,
                                              child: SingleChildScrollView(
                                                scrollDirection:
                                                    Axis.horizontal,
                                                child: Row(
                                                    children:
                                                        promotionProvider.qrData
                                                                    .urls !=
                                                                null
                                                            ? promotionProvider
                                                                .qrData.urls!
                                                                .map(
                                                                    (e) =>
                                                                        InkWell(
                                                                          splashColor: Colors
                                                                              .blue
                                                                              .shade100,
                                                                          borderRadius:
                                                                              BorderRadius.circular(10),
                                                                          onTap:
                                                                              () async {
                                                                            bool
                                                                                found =
                                                                                await canLaunchUrl(Uri.parse(e.link!));
                                                                            if (found) {
                                                                              await launchUrl(Uri.parse(e.link!), mode: LaunchMode.externalApplication);
                                                                            } else {
                                                                              message(message: '${e.description!} банкны апп олдсонгүй.', context: context);
                                                                            }
                                                                          },
                                                                          child: Container(
                                                                              margin: const EdgeInsets.all(10),
                                                                              child: Image.network(
                                                                                e.logo!,
                                                                                width: 60,
                                                                              )),
                                                                        ))
                                                                .toList()
                                                            : []),
                                              ),
                                            ),
                                          ),
                                    box,
                                    Container(
                                      margin: const EdgeInsets.symmetric(
                                          vertical: 5),
                                      child: CustomButton(
                                        ontap: () => promotionProvider
                                            .checkPayment(context),
                                        text: 'Төлбөр шалгах',
                                      ),
                                    ),
                                    box,
                                  ],
                                ),
                        ],
                      )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget branch(Sector e) {
    return InkWell(
      onTap: () => setState(() => selectedBranch = e.id),
      child: Container(
        padding: const EdgeInsets.all(10),
        margin: const EdgeInsets.only(top: 10, left: 5, right: 5),
        decoration: BoxDecoration(
          boxShadow: [Constants.defaultShadow],
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(
              Icons.home,
              color: selectedBranch == e.id
                  ? AppColors.secondary
                  : AppColors.primary,
            ),
            Constants.boxH10,
            Text(e.name!),
          ],
        ),
      ),
    );
  }

  solveQTY() {
    int blenght =
        widget.promo.bundles != null ? widget.promo.bundles!.length : 0;
    int glength = widget.promo.gift != null ? widget.promo.gift!.length : 0;
    int qty = blenght + glength;
    return qty;
  }

  solveTotal() {
    double total = 0;
    double tbundle = widget.promo.bundles!.fold(
        0.0,
        (previousValue, element) =>
            total = total + (element['price'] * element['qty']));
    return tbundle;
  }
}

product(e, String noImage) {
  return Stack(
    children: [
      Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.white,
            boxShadow: [Constants.defaultShadow]),
        padding: const EdgeInsets.all(5),
        child: Column(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    fit: BoxFit.cover,
                    scale: 1,
                    image: NetworkImage(noImage),
                  ),
                ),
              ),
            ),
            Text(
              e['name'] != null ? e['name'].toString() : '-',
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text(
                  '${e['price'] != null ? e['price'].toString() : '-'} ₮',
                  style: TextStyle(color: Colors.red.shade600),
                ),
              ],
            ),
          ],
        ),
      ),
      Positioned(
        right: 3,
        top: 3,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            'x ${e['qty']}',
            style: const TextStyle(color: Colors.white),
          ),
        ),
      )
    ],
  );
}
