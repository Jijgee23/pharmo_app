// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:pharmo_app/models/branch.dart';
import 'package:pharmo_app/models/filters.dart';
import 'package:pharmo_app/models/products.dart';
import 'package:pharmo_app/widgets/dialog_and_messages/snack_message.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeProvider extends ChangeNotifier {
  int currentIndex = 0;
  bool invisible = false;
  String selectedCustomerName = '';
  int selectedCustomerId = 0;
  String? userEmail;
  String? userRole;
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
  List<Filters> categories = <Filters>[];
  List<Manufacturer> mnfrs = <Manufacturer>[];
  List<Manufacturer> vndrs = <Manufacturer>[];


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

  getFilters() async {
    try {
      final accestoken = await getAccessToken();
      final response = await http.get(
        Uri.parse('${dotenv.env['SERVER_URL']}product/filters/'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $accestoken',
        },
      );
      if (response.statusCode == 200) {
        Map res = jsonDecode(utf8.decode(response.bodyBytes));

        categories = (res['cats'] as List)
            .map((data) => Filters.fromJson(data))
            .toList();
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

  filter(String type, int filters, int page, int pageSize) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString("access_token");
      String bearerToken = "Bearer $token";
      final response = await http.get(
          Uri.parse(
              '${dotenv.env['SERVER_URL']}products/?$type=[$filters]&page=$page&page_size=$pageSize'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': bearerToken,
          });
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

  filterCate(int filters, int page, int pageSize) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString("access_token");
      String bearerToken = "Bearer $token";
      final response = await http.get(
          Uri.parse(
              '${dotenv.env['SERVER_URL']}products/?category=$filters&page=$page&page_size=$pageSize'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': bearerToken,
          });
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

  getUserInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? useremail = prefs.getString('useremail');
    String? userrole = prefs.getString('userrole');
    userEmail = useremail.toString();
    userRole = userrole.toString();
    notifyListeners();
  }

  getSelectedUser(int customerId, String customerName) {
    selectedCustomerId = customerId;
    selectedCustomerName = customerName;
    notifyListeners();
  }

  getBasketId() async {
    final accestoken = await getAccessToken();
    final response = await http.get(
      Uri.parse('${dotenv.env['SERVER_URL']}get_basket/'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $accestoken',
      },
    );
    final res = jsonDecode(utf8.decode(response.bodyBytes));
    if (response.statusCode == 200) {
      basketId = res['id'];
    }
    notifyListeners();
  }

  getCustomerBranch() async {
    try {
      final accestoken = await getAccessToken();
      final response = await http.post(
          Uri.parse('${dotenv.env['SERVER_URL']}seller/customer_branch/'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': 'Bearer $accestoken',
          },
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
    final accestoken = await getAccessToken();
    String bearerToken = "Bearer $accestoken";
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
              headers: <String, String>{
                'Content-Type': 'application/json; charset=UTF-8',
                'Authorization': bearerToken,
              },
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
      final accestoken = await getAccessToken();
      final response = await http.post(
          Uri.parse('${dotenv.env['SERVER_URL']}seller/search_by_location/'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': 'Bearer $accestoken',
          },
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

  

  getAccessToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('access_token');
    return token;
  }
}
