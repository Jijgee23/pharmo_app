import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:pharmo_app/models/order_list.dart';
import 'package:pharmo_app/utilities/utils.dart';
import 'package:pharmo_app/widgets/dialog_and_messages/snack_message.dart';

class PharmProvider extends ChangeNotifier {
  String baseUrl = '${dotenv.env['SERVER_URL']}';
  List<PharmFullInfo> pharmList = <PharmFullInfo>[];
  List<PharmFullInfo> customeList = <PharmFullInfo>[];
  List<PharmFullInfo> fullList = <PharmFullInfo>[];
  List<PharmFullInfo> goodlist = <PharmFullInfo>[];
  List<PharmFullInfo> badlist = <PharmFullInfo>[];
  List<PharmFullInfo> limitedlist = <PharmFullInfo>[];
  List<PharmFullInfo> filteredList = <PharmFullInfo>[];
  List<OrderList> orderList = <OrderList>[];
  getPharmacyList() async {
    try {
      final beareToken = await getAccessToken();
      final response = await http.get(
        Uri.parse('${baseUrl}seller/pharmacy_list/'),
        headers: getHeader(beareToken),
      );
      getApiInformation('GET PHARMACY LIST', response);
      if (response.statusCode == 200) {
        Map data = jsonDecode(utf8.decode(response.bodyBytes));
        List<dynamic> pharms = data['pharmacies'];
        fullList.clear();
        pharmList.clear();
        customeList.clear();
        badlist.clear();
        goodlist.clear();
        limitedlist.clear();
        for (int i = 0; i < pharms.length; i++) {
          fullList.add(PharmFullInfo.fromJson(pharms[i]));
          final bool isCustomer = pharms[i]['isCustomer'];
          final bool isBad = pharms[i]['isBad'];
          final bool isLimited = pharms[i]['debtLimit'] != 0 &&
              pharms[i]['debt'] != 0 &&
              pharms[i]['debt'] > pharms[i]['debtLimit'];
          if (isCustomer == true) {
            customeList.add(PharmFullInfo.fromJson(pharms[i]));
          } else {
            pharmList.add(PharmFullInfo.fromJson(pharms[i]));
          }
          if (isBad == true) {
            badlist.add(PharmFullInfo.fromJson(pharms[i]));
          }
          if (isBad == false && isCustomer == true && isLimited == false) {
            goodlist.add(PharmFullInfo.fromJson(pharms[i]));
          }
          if (isLimited == true) {
            limitedlist.add(PharmFullInfo.fromJson(pharms[i]));
          }
          notifyListeners();
        }
      }
      notifyListeners();
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  List<Customer> filteredCustomers = <Customer>[];

  getOrderList(int customerId) async {
    try {
      final token = await getAccessToken();
      final response = await http.get(
        Uri.parse(
            '${dotenv.env['SERVER_URL']}seller/order_history/?pharmacyId=$customerId'),
        headers: getHeader(token),
      );
      notifyListeners();
      if (response.statusCode == 200) {
        List<dynamic> ordList = jsonDecode(utf8.decode(response.bodyBytes));
        for (int i = 0; i < ordList.length; i++) {
          orderList.add(OrderList.fromJson((ordList[i])));
        }
      }
      notifyListeners();
    } catch (e) {
      // showFailedMessage(message: 'Дахин оролдоно уу.', context: context);
      notifyListeners();
    }
  }

  /// харилцагч
  getCustomers(int page, int size, BuildContext c) async {
    try {
      final beareToken = await getAccessToken();
      final response = await http.get(
        Uri.parse('${baseUrl}seller/customer/?page=$page&page_size=$size'),
        headers: getHeader(beareToken),
      );
      getApiInformation('GET CUSTOMER LIST', response);
      if (response.statusCode == 200) {
        Map data = jsonDecode(utf8.decode(response.bodyBytes));
        filteredCustomers.clear();
        List<dynamic> pharms = data['results'];
        filteredCustomers = pharms.map((p) => Customer.fromJson(p)).toList();
        notifyListeners();
      } else {
        message(message: 'Алдаа гарлаа', context: c);
      }
      notifyListeners();
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  getEndPoint(String type, String v) {
    if (type == 'name') {
      return '?name__icontains=$v';
    } else if (type == 'phone') {
      return '?phone=$v';
    } else {
      return '?rn=$v';
    }
  }

  filtCustomers(String type, String v, BuildContext c) async {
    try {
      final beareToken = await getAccessToken();
      final response = await http.get(
        Uri.parse('${baseUrl}seller/customer/${getEndPoint(type, v)}'),
        headers: getHeader(beareToken),
      );
      getApiInformation('FILTER CUSTOMER LIST', response);
      if (response.statusCode == 200) {
        Map data = jsonDecode(utf8.decode(response.bodyBytes));
        filteredCustomers.clear();
        List<dynamic> pharms = data['results'];
        filteredCustomers = pharms.map((p) => Customer.fromJson(p)).toList();
        notifyListeners();
      } else {
        message(message: 'Алдаа гарлаа', context: c);
      }
      notifyListeners();
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future registerCustomer(
      String name, String phone, String note, BuildContext context) async {
    try {
      final beareToken = await getAccessToken();
      final response = await http.post(Uri.parse('${baseUrl}seller/customer/'),
          headers: getHeader(beareToken),
          body: jsonEncode({"name": name, "phone": phone, "note": note}));
      getApiInformation('REGISTER CUSTOMER', response);
      if (response.statusCode == 201) {
        message(message: 'Амжилттай бүртгэгдлээ.', context: context);
      } else {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        if (data['error'] == 'name_exists!') {
          message(message: 'Нэр бүртгэлтэй байна!', context: context);
        } else {
          message(message: 'Алдаа гарлаа!', context: context);
        }
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future getCustomerFavs(dynamic customerId, BuildContext context) async {
    try {
      final beareToken = await getAccessToken();
      final response = await http.post(
          Uri.parse('${baseUrl}seller/customer_favs/'),
          headers: getHeader(beareToken),
          body: jsonEncode({"customer_id": customerId}));
      getApiInformation('GET CUSTOMER FAVS', response);
      if (response.statusCode == 201) {
        // final data = jsonDecode(utf8.decode(response.bodyBytes));
      } else {}
    } catch (e) {
      debugPrint(e.toString());
    }
  }
}

class PharmFullInfo {
  int id;
  String name;
  bool isCustomer;
  int badCnt;
  bool isBad;
  double debt;
  double debtLimit;
  PharmFullInfo(
    this.id,
    this.name,
    this.isCustomer,
    this.badCnt,
    this.isBad,
    this.debt,
    this.debtLimit,
  );
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'isCustomer': isCustomer,
      'badCnt': badCnt,
      'isBad': isBad,
      'debt': debt,
      'debtLimit': debtLimit,
    };
  }

  factory PharmFullInfo.fromJson(Map<String, dynamic> json) {
    return PharmFullInfo(
      json['id'],
      json['name'],
      json['isCustomer'],
      json['badCnt'],
      json['isBad'],
      json['debt'].toDouble(),
      json['debtLimit'].toDouble(),
    );
  }
}

class Customer {
  int? id;
  String? name;
  String? rn;
  String? phone;
  String? phone2;
  String? phone3;

  // Constructor
  Customer({
    this.id,
    this.name,
    this.rn,
    this.phone,
    this.phone2,
    this.phone3,
  });

  // Factory method to create a `Customer` instance from JSON
  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['id'],
      name: json['name'],
      rn: json['rn'].toString(),
      phone: json['phone'].toString(),
      phone2: json['phone2'].toString(),
      phone3: json['phone3'].toString(),
    );
  }

  // Method to convert a `Customer` instance to JSON (optional)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'rn': rn,
      'phone': phone,
      'phone2': phone2,
      'phone3': phone3,
    };
  }
}
