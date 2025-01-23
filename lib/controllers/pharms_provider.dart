import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:pharmo_app/controllers/basket_provider.dart';
import 'package:pharmo_app/controllers/home_provider.dart';
import 'package:pharmo_app/models/order_list.dart';
import 'package:pharmo_app/utilities/sizes.dart';
import 'package:pharmo_app/utilities/utils.dart';
import 'package:pharmo_app/widgets/dialog_and_messages/snack_message.dart';
import 'package:provider/provider.dart';

class PharmProvider extends ChangeNotifier {
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
      final response = await apiGet('seller/pharmacy_list/');
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
      final response =
          await apiGet('seller/order_history/?pharmacyId=$customerId');
      if (response.statusCode == 200) {
        List<dynamic> ordList = jsonDecode(utf8.decode(response.bodyBytes));
        for (int i = 0; i < ordList.length; i++) {
          orderList.add(OrderList.fromJson((ordList[i])));
        }
      }
    } catch (e) {
      notifyListeners();
    }
  }

  /// харилцагч
  getCustomers(int page, int size, BuildContext c) async {
    try {
      final response = await apiRequest(
          method: 'GET',
          endPoint: 'seller/customer/?page=$page&page_size=$size');
      if (response!.statusCode == 200) {
        Map data = convertData(response);
        filteredCustomers.clear();
        List<dynamic> pharms = data['results'];
        filteredCustomers = pharms.map((p) => Customer.fromJson(p)).toList();
        notifyListeners();
      } else {
        message('Алдаа гарлаа');
      }
      notifyListeners();
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  getCustomerDetail(int custId, BuildContext c) async {
    try {
      final response =
          await apiRequest(method: 'GET', endPoint: 'seller/customer/$custId');
      if (response!.statusCode == 200) {
        dynamic data = convertData(response);
        customerDetail = CustomerDetail.fromJson(data);
      } else {
        message(wait);
      }
    } catch (e) {
      debugPrint(e.toString());
    }
    notifyListeners();
  }

  sendCustomerLocation(int custId, BuildContext c) async {
    print('CSUTOMER ID: $custId');
    try {
      final home = Provider.of<HomeProvider>(c, listen: false);
      final response = await apiPatch(
          'seller/customer/$custId/update_location/',
          jsonEncode({
            "lat": home.currentLatitude,
            "lng": home.currentLongitude,
          }));
      if (response.statusCode == 200) {
        message('Амжилттай');
      } else {
        message('Алдаа гарлаа');
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  CustomerDetail customerDetail = CustomerDetail();

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
      final response = await apiGet('seller/customer/${getEndPoint(type, v)}');
      if (response.statusCode == 200) {
        Map data = convertData(response);
        filteredCustomers.clear();
        List<dynamic> pharms = data['results'];
        filteredCustomers = pharms.map((p) => Customer.fromJson(p)).toList();
      } else {
        message('Алдаа гарлаа');
      }
    } catch (e) {
      debugPrint(e.toString());
    }
    notifyListeners();
  }

  editSellerOrder(String note, String pt, int orderId, BuildContext c) async {
    try {
      final response = await apiPatch(
          'seller/order/$orderId/', jsonEncode({"note": note, "payType": pt}));
      if (response.statusCode == 200) {
        message('Амжилттай засагдлаа');
        notifyListeners();
      } else {
        message('Алдаа гарлаа');
      }
      notifyListeners();
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  List<SellerOrder> orderDets = <SellerOrder>[];
  clearOrderDets() {
    orderDets.clear();
  }

  getSellerOrderDetail(int oId, BuildContext c) async {
    try {
      final response = await apiGet('seller/order/$oId/');
      if (response.statusCode == 200 && response.body != null) {
        clearOrderDets();
        var data = convertData(response);
        return data;
      } else {
        message('Алдаа гарлаа');
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  changeItemQty(
      {required int oId,
      required int itemId,
      required int qty,
      required BuildContext context}) async {
    try {
      final basketProvider =
          Provider.of<BasketProvider>(context, listen: false);
      dynamic check = await basketProvider.checkItemQty(itemId, qty);
      if (check['errorType'] == 0) {
        message('Бараа дууссан');
      } else if (check['errorType'] == 1) {
        final response = await apiPatch('seller/order/$oId/update_item/',
            jsonEncode({"itemId": itemId, "qty": qty}));
        if (response.statusCode == 200) {
          return buildResponse(1, response, 'Амжилттай өөрлөгдлөө');
        } else if (response.statusCode == 400) {
          if (checker(convertData(response), 'order') == true) {
            return buildResponse(4, null, 'Тухайн захиалгыг засах боломжгүй!');
          } else if (checker(convertData(response), 'itemId') == true) {
            return buildResponse(4, null, 'Бараа олдсонгүй!');
          } else {
            return buildResponse(2, null, 'Алдаа гарлаа');
          }
        } else {
          return buildResponse(2, null, 'Алдаа гарлаа');
        }
      } else if (check['errorType'] == 2) {
        return buildResponse(3, null, 'Барааны үлдэгдэл хүрэлцэхгүй байна.');
      } else {
        return buildResponse(2, null, 'Алдаа гарлаа');
      }
    } catch (e) {
      debugPrint(e.toString());
      return buildResponse(2, null, 'Алдаа гарлаа');
    }
  }

  Future registerCustomer(String name, String rn, String email, String phone,
      String? note, String? lat, String? lng, BuildContext context) async {
    try {
      var body = {
        "name": name,
        "rn": rn,
        "email": email,
        "phone": phone,
        note ?? "note": note,
        "lat": lat,
        "lng": lng
      };
      await Provider.of<HomeProvider>(context, listen: false).getPosition();
      var response = await apiPost('seller/customer/', body);
      if (response.statusCode == 201) {
        message('Амжилттай бүртгэгдлээ.');
      } else {
        final data = convertData(response);
        if (data['error'] == 'name_exists!') {
          message('Нэр бүртгэлтэй байна!');
        } else {
          message('Алдаа гарлаа!');
        }
      }
      notifyListeners();
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future editCustomer(
      {required int id,
      required String name,
      required String rn,
      required String email,
      required String phone,
      String? phone2,
      String? phone3,
      required String note,
      double? lat,
      double? lng,
      required BuildContext context}) async {
    try {
      var body = jsonEncode({
        "name": name,
        "rn": rn,
        "email": email,
        "phone": phone,
        "phone2": phone2,
        "phone3": phone3,
        "note": note,
        "lat": lat,
        "lng": lng
      });
      await Provider.of<HomeProvider>(context, listen: false).getPosition();
      final response = await apiPatch('seller/customer/$id/', body);
      if (response.statusCode == 200) {
        message('Амжилттай засагдлаа.');
      } else {
        final data = convertData(response);
        if (data['error'] == 'name_exists!') {
          message('Нэр бүртгэлтэй байна!');
        } else {
          message('Алдаа гарлаа!');
        }
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future getCustomerFavs(dynamic customerId) async {
    try {
      final response =
          await apiPost('seller/customer_favs/', {"customer_id": customerId});
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
  String? note;
  bool? location;
  bool? loanBlock;
  int? addedUserId;

  // Constructor
  Customer(
      {this.id,
      this.name,
      this.rn,
      this.phone,
      this.phone2,
      this.phone3,
      this.note,
      this.location,
      this.loanBlock,
      this.addedUserId});

  // Factory method to create a `Customer` instance from JSON
  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['id'],
      name: json['name'],
      rn: json['rn'],
      phone: json['phone'].toString(),
      phone2: json['phone2'].toString(),
      phone3: json['phone3'].toString(),
      note: json['note'].toString(),
      addedUserId: json['added_by_id'],
      location: json['location'],
      loanBlock: json['loanBlock'],
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
      'note': note,
      'location': location,
      'loanBlock': loanBlock
    };
  }
}

class SellerOrder {
  final int id;
  final String orderNo;
  final String customer;
  final double totalPrice;
  final int totalCount;
  final String status;
  final String process;
  final String createdOn;
  final String payType;
  final String note;
  final List<OrderItem> items;

  SellerOrder({
    required this.id,
    required this.orderNo,
    required this.customer,
    required this.totalPrice,
    required this.totalCount,
    required this.status,
    required this.process,
    required this.createdOn,
    required this.payType,
    required this.note,
    required this.items,
  });

  // Factory constructor for parsing JSON data
  factory SellerOrder.fromJson(Map<String, dynamic> json) {
    return SellerOrder(
      id: json['id'],
      orderNo: json['orderNo'].toString(),
      customer: json['customer'].toString(),
      totalPrice: (json['totalPrice'] as num).toDouble(),
      totalCount: json['totalCount'],
      status: json['status'].toString(),
      process: json['process'].toString(),
      createdOn: json['createdOn'].toString(),
      payType: json['payType'].toString(),
      note: json['note'].toString(),
      items: (json['items'] as List<dynamic>)
          .map((item) => OrderItem.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  // Method to convert an instance back to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'orderNo': orderNo,
      'customer': customer,
      'totalPrice': totalPrice,
      'totalCount': totalCount,
      'status': status,
      'process': process,
      'createdOn': createdOn,
      'payType': payType,
      'note': note,
      'items': items.map((item) => item.toJson()).toList(),
    };
  }
}

class OrderItem {
  final String itemName;
  final double itemPrice;
  final int iQty;
  final int itemQty;
  final double itemTotalPrice;
  final String itemnameId;
  final int productId;

  OrderItem({
    required this.itemName,
    required this.itemPrice,
    required this.iQty,
    required this.itemQty,
    required this.itemTotalPrice,
    required this.itemnameId,
    required this.productId,
  });

  // Factory constructor for parsing JSON data
  factory OrderItem.fromJson(Map<String, dynamic> json) {
    // print('TYPE: ${json['itemname_id'].runtimeType}');
    return OrderItem(
      itemName: json['itemName'],
      itemPrice: (json['itemPrice'] as num).toDouble(),
      iQty: json['iQty'],
      itemQty: json['itemQty'],
      itemTotalPrice: (json['itemTotalPrice'] as num).toDouble(),
      itemnameId: json['itemname_id'].toString(),
      productId: json['product_id'],
    );
  }

  // Method to convert an instance back to JSON
  Map<String, dynamic> toJson() {
    return {
      'itemName': itemName,
      'itemPrice': itemPrice,
      'iQty': iQty,
      'itemQty': itemQty,
      'itemTotalPrice': itemTotalPrice,
      'itemname_id': itemnameId,
      'product_id': productId,
    };
  }
}

class CustomerDetail {
  int? id;
  String? name;
  String? rn;
  String? email;
  String? phone;
  String? phone2;
  String? phone3;
  String? note;
  bool? isCmp;
  double? lat;
  double? lng;
  String? created;
  int? addedById;
  bool? loanBlock;
  double? loanLimit;
  bool? loanLimitUse;
  bool? loanBalBlock;
  List<Map<String, dynamic>>? custType;

  CustomerDetail({
    this.id,
    this.name,
    this.rn,
    this.email,
    this.phone,
    this.phone2,
    this.phone3,
    this.note,
    this.isCmp,
    this.lat,
    this.lng,
    this.created,
    this.addedById,
    this.loanBlock,
    this.loanLimit,
    this.loanLimitUse,
    this.loanBalBlock,
    this.custType,
  });

  // Factory method to create a CustomerDetail instance from JSON
  factory CustomerDetail.fromJson(Map<String, dynamic> json) {
    print('DATA TYPE: ${json['added_by_id'].runtimeType}');
    return CustomerDetail(
      id: json['id'],
      name: json['name'],
      rn: json['rn'],
      email: json['email'],
      phone: json['phone'],
      phone2: json['phone2'],
      phone3: json['phone3'],
      note: json['note'],
      isCmp: json['is_cmp'],
      lat: json['lat'],
      lng: json['lng'],
      created: json['created'].toString(),
      addedById: json['added_by_id'],
      loanBlock: json['loan_block'],
      loanLimit: json['loan_limit'].toDouble(),
      loanLimitUse: json['loan_limit_use'],
      loanBalBlock: json['loan_bal_block'],
      custType: List<Map<String, dynamic>>.from(json['cust_type']),
    );
  }
}
