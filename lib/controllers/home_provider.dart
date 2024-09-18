// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:pharmo_app/controllers/auth_provider.dart';
import 'package:pharmo_app/controllers/basket_provider.dart';
import 'package:pharmo_app/controllers/promotion_provider.dart';
import 'package:pharmo_app/models/branch.dart';
import 'package:pharmo_app/models/category.dart';
import 'package:pharmo_app/models/products.dart';
import 'package:pharmo_app/models/sector.dart';
import 'package:pharmo_app/models/supplier.dart';
import 'package:pharmo_app/utilities/colors.dart';
import 'package:pharmo_app/utilities/utils.dart';
import 'package:pharmo_app/views/pharmacy/drawer_menus/promotion/buying_promo.dart';
import 'package:pharmo_app/views/pharmacy/drawer_menus/promotion/marked_promo.dart';
import 'package:pharmo_app/widgets/dialog_and_messages/snack_message.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  String payType = '';
  String orderType = 'NODELIVERY';
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
  List<Supplier> _supList = <Supplier>[];
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
      final bearerToken = await getAccessToken();
      final response = await http.get(
          Uri.parse(!searching
              ? '${dotenv.env['SERVER_URL']}products/?page=$pageKey&page_size=$pageSize'
              : '${dotenv.env['SERVER_URL']}products/search/?k=$queryType&v=$query'),
          headers: getHeader(bearerToken));
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
      final bearerToken = await getAccessToken();
      final response = await http.get(
          Uri.parse('${dotenv.env['SERVER_URL']}branch'),
          headers: getHeader(bearerToken));
      if (response.statusCode == 200) {
        List<dynamic> res = jsonDecode(utf8.decode(response.bodyBytes));
        branches = (res).map((data) => Sector.fromJson(data)).toList();
      } else {
        showFailedMessage(
            message: 'Түр хүлээгээд дахин оролдоно уу!', context: context);
      }
    } catch (e) {
      showFailedMessage(
          message: 'Өгөгдөл авчрах үед алдаа гарлаа. Админтай холбогдоно уу!',
          context: context);
    }
  }

  // хямдралтай, эрэлттэй, шинэ бараа
  filterProducts(String filter) async {
    try {
      final bearerToken = await getAccessToken();
      final response = await http.get(
          Uri.parse('${dotenv.env['SERVER_URL']}products/?$filter'),
          headers: getHeader(bearerToken));
      if (response.statusCode == 200) {
        Map res = jsonDecode(utf8.decode(response.bodyBytes));
        List<Product> prods = (res['results'] as List)
            .map((data) => Product.fromJson(data))
            .toList();
        return prods;
      }
    } catch (e) {
      debugPrint('error============= on filterProduct > ${e.toString()}');
    }
  }

  // Онцлох урамшуулал харуулах
  showMarkedPromos(BuildContext context, PromotionProvider promotionProvider) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            child: Container(
                height: double.infinity,
                padding:
                    const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                decoration: BoxDecoration(
                  color: AppColors.cleanWhite,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    Expanded(
                      child: PageView(
                        scrollDirection: Axis.horizontal,
                        controller: pageController,
                        pageSnapping: true,
                        children: promotionProvider.markedPromotions
                            .map((e) => (e.promoType == 2)
                                ? BuyinPromo(promo: e)
                                : MarkedPromoWidget(promo: e))
                            .toList(),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        InkWell(
                          onTap: () => pageController.previousPage(
                              duration: const Duration(milliseconds: 500),
                              curve: Curves.linear),
                          child: const Text('Өмнөх'),
                        ),
                        InkWell(
                            onTap: () {
                              if (pageController.page ==
                                  promotionProvider.markedPromotions.length -
                                      1) {
                                Navigator.pop(context);
                              } else {
                                pageController.nextPage(
                                    duration: const Duration(milliseconds: 500),
                                    curve: Curves.linear);
                              }
                            },
                            child: const Text('Дараах')),
                      ],
                    )
                  ],
                )),
          );
        });
  }

  // Ангилалийн жагсаалт авах
  getFilters() async {
    try {
      final accestoken = await getAccessToken();
      final response = await http.get(
        Uri.parse('${dotenv.env['SERVER_URL']}product/filters/'),
        headers: getHeader(accestoken),
      );
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
      }
      notifyListeners();
    } catch (e) {
      debugPrint(e.toString());
    }
  }

// Бараа ангиллаар шүүх
  filter(String type, int filters, int page, int pageSize) async {
    try {
      final bearerToken = await getAccessToken();
      final response = await http.get(
          Uri.parse(
              '${dotenv.env['SERVER_URL']}products/?$type=[$filters]&page=$page&page_size=$pageSize'),
          headers: getHeader(bearerToken));
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
      final bearerToken = await getAccessToken();
      final response = await http.get(
          Uri.parse(
              '${dotenv.env['SERVER_URL']}products/?category=[$id]&page=$page&page_size=$pageSize'),
          headers: getHeader(bearerToken));
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
      final bearerToken = await getAccessToken();
      int? id = prefs.getInt('suppID');
      final response = await http.get(
          Uri.parse('${dotenv.env['SERVER_URL']}suppliers'),
          headers: getHeader(bearerToken));
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
    final bearertoken = await getAccessToken();
    final response = await http.post(
        Uri.parse('${dotenv.env['SERVER_URL']}pick/'),
        headers: getHeader(bearertoken),
        body: jsonEncode({'supplierId': supId}));
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
    final bearerToken = await getAccessToken();
    final response = await http.get(
      Uri.parse('${dotenv.env['SERVER_URL']}get_basket/'),
      headers: getHeader(bearerToken),
    );
    final res = jsonDecode(utf8.decode(response.bodyBytes));
    if (response.statusCode == 200) {
      basketId = res['id'];
    }
    notifyListeners();
  }

  getCustomerBranch() async {
    try {
      final bearerToken = await getAccessToken();
      final response = await http.post(
          Uri.parse('${dotenv.env['SERVER_URL']}seller/customer_branch/'),
          headers: getHeader(bearerToken),
          body: jsonEncode({'customerId': selectedCustomerId}));
      branchList.clear();
      if (response.statusCode == 200) {
        List<dynamic> res = jsonDecode(utf8.decode(response.bodyBytes));
        for (int i = 0; i < res.length; i++) {
          branchList.add(Branch.fromJson(res[i]));
        }
        selectedBranchId = res[0]['id'];
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<Map<String, String>> getDeviceInfo() async {
    final bearerToken = await getAccessToken();
    DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
    Map<String, String> deviceData = {};
    try {
      if (Platform.isAndroid) {
        AndroidDeviceInfo androidInfo = await deviceInfoPlugin.androidInfo;
        deviceData = {
          "deviceId": androidInfo.id,
          "platform": 'android',
          "brand": androidInfo.brand,
          "model": androidInfo.model,
          "modelVersion": androidInfo.device,
          "os": Platform.operatingSystem,
          "osVersion": Platform.operatingSystemVersion,
        };
      } else if (Platform.isIOS) {
        IosDeviceInfo iosInfo = await deviceInfoPlugin.iosInfo;
        deviceData = {
          "deviceId": iosInfo.identifierForVendor ?? "unknown",
          "platform": "ios",
          "brand": "Apple",
          "model": iosInfo.name,
          "modelVersion": iosInfo.utsname.machine,
          "os": "iOS",
          "osVersion": iosInfo.systemVersion,
        };
      }
      final response =
          await http.post(Uri.parse('${dotenv.env['SERVER_URL']}device_id/'),
              headers: getHeader(bearerToken),
              body: jsonEncode({
                'deviceId': deviceData['deviceId'],
                'platform': deviceData['platform'],
                'brand': deviceData['brand'],
                'model': deviceData['model'],
                'modelVersion': deviceData['modelVersion'],
                'os': deviceData['os'],
                'osVersion': deviceData['osVersion'],
              }));
      if (response.statusCode == 200) {
        debugPrint('Device info sent');
      } else {
        debugPrint('Device info not sent');
      }
      return deviceData;
    } catch (e) {
      debugPrint('$e');
    }
    return deviceData;
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
      final bearerToken = await getAccessToken();
      final response = await http.post(
          Uri.parse('${dotenv.env['SERVER_URL']}seller/search_by_location/'),
          headers: getHeader(bearerToken),
          body: jsonEncode({
            'lat': currentLatitude,
            'lon': currentLongitude,
          }));
      if (response.statusCode == 200) {
        if (jsonDecode(utf8.decode(response.bodyBytes).toString()) ==
            'not found') {
          showFailedMessage(message: 'Харилцагч олдсонгүй', context: context);
        } else {
          Map<String, dynamic> res =
              jsonDecode(utf8.decode(response.bodyBytes));
          showSuccessMessage(
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
        showFailedMessage(message: 'Серверийн алдаа', context: context);
      }
    } catch (e) {
      showFailedMessage(
          message: 'Интернет холболтоо шалгана уу!.', context: context);
    }
  }

  deactiveUser(String password, BuildContext context) async {
    try {
      final bearerToken = await getAccessToken();
      final response = await http.patch(
        Uri.parse('${dotenv.env['SERVER_URL']}auth/delete_user_account/'),
        headers: getHeader(bearerToken),
        body: jsonEncode({'pwd': password}),
      );
      debugPrint(response.statusCode.toString());
      if (response.statusCode == 200) {
        AuthController().logout(context);
        showSuccessMessage(
            message: '$userEmail и-мейл хаягтай таний бүртгэл устгагдлаа',
            context: context);
      } else {
        showFailedMessage(message: 'Алдаа гарлаа', context: context);
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  setQueryType(String type) {
    queryType = type;
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
