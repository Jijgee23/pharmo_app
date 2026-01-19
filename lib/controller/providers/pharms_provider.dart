import 'package:pharmo_app/controller/a_controlller.dart';
import 'package:pharmo_app/controller/models/delivery.dart';
import 'package:pharmo_app/widgets/dialog_and_messages/snack_message.dart';
import 'package:pharmo_app/application/utilities/a_utils.dart';

class PharmProvider extends ChangeNotifier {
  List<Customer> filteredCustomers = <Customer>[];
  List<SellerOrder> orderDets = <SellerOrder>[];
  CustomerDetail customerDetail = CustomerDetail();
  List<Zone> zones = [];
  Zone selectedZone = Zone(id: -1, name: 'Бүс сонгох');
  void reset() {
    filteredCustomers.clear();
    orderDets.clear();
    customerDetail = CustomerDetail();
    zones.clear();
    selectedZone = Zone(id: -1, name: 'Бүс сонгох');
    notifyListeners();
  }

  /// харилцагч
  getCustomers(int page, int size, BuildContext c) async {
    try {
      final response =
          await api(Api.get, 'seller/customer/?page=$page&page_size=$size/');
      if (response!.statusCode == 200) {
        Map data = convertData(response);
        filteredCustomers.clear();
        List<dynamic> pharms = data['results'];
        filteredCustomers = pharms.map((p) => Customer.fromJson(p)).toList();
        notifyListeners();
      } else {
        messageWarning('Алдаа гарлаа');
      }
      notifyListeners();
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  filtCustomers(String type, String v) async {
    try {
      final response =
          await api(Api.get, 'seller/customer/${getEndPoint(type, v)}');
      if (response!.statusCode == 200) {
        Map data = convertData(response);
        filteredCustomers.clear();
        List<dynamic> pharms = data['results'];
        filteredCustomers = pharms.map((p) => Customer.fromJson(p)).toList();
      } else {
        messageWarning('Алдаа гарлаа');
      }
    } catch (e) {
      debugPrint(e.toString());
    }
    notifyListeners();
  }

  Future<Map<String, dynamic>> getCustomerDetail(int custId) async {
    Map<String, dynamic> result = {};
    try {
      final response = await api(Api.get, 'seller/customer/$custId');
      if (response!.statusCode == 200) {
        dynamic data = convertData(response);
        result = data;
        customerDetail = CustomerDetail.fromJson(data);
      } else {
        messageWarning(wait);
      }
    } catch (e) {
      debugPrint(e.toString());
    }
    notifyListeners();
    return result;
  }

  sendCustomerLocation(int custId, BuildContext c) async {
    try {
      final home = Provider.of<HomeProvider>(c, listen: false);
      final response = await api(
          Api.patch, 'seller/customer/$custId/update_location/',
          body: {
            "lat": home.currentLatitude,
            "lng": home.currentLongitude,
          });
      if (response!.statusCode == 200) {
        messageComplete('Амжилттай');
      } else {
        messageWarning('Алдаа гарлаа');
      }
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

  editSellerOrder(String note, String pt, int orderId, BuildContext c) async {
    try {
      final response = await api(Api.patch, 'seller/order/$orderId/',
          body: {"note": note, "payType": pt});
      if (response!.statusCode == 200) {
        messageComplete('Амжилттай засагдлаа');
        notifyListeners();
      } else {
        messageWarning('Алдаа гарлаа');
      }
      notifyListeners();
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  clearOrderDets() {
    orderDets.clear();
  }

  Stream<MyOrderModel>? getSellerOrderDetail(int oId) async* {
    MyOrderModel? result;
    try {
      final response = await api(Api.get, 'seller/order/$oId/');
      if (response!.statusCode == 200 && response.body != null) {
        result = MyOrderModel.fromJson(convertData(response));
      }
    } catch (e) {
      messageError('Серверийн алдаа');
      debugPrint(e.toString());
    }
    yield result!;
  }

  changeItemQty(
      {required int oId,
      required int itemId,
      required int qty,
      required BuildContext context}) async {
    try {
      final response = await api(
        Api.patch,
        'seller/order/$oId/update_item/',
        body: {"itemId": itemId, "qty": qty},
      );
      if (response!.statusCode == 200) {
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
        "lng": lng,
        "zone_id": selectedZone.id
      };
      await Provider.of<HomeProvider>(context, listen: false).getPosition();
      if (selectedZone.id == -1) {
        messageWarning('Бүс сонгоно уу!');
      } else {
        var response = await api(Api.post, 'seller/customer/', body: body);
        if (response!.statusCode == 201) {
          messageComplete('Амжилттай бүртгэгдлээ.');
        } else {
          final data = convertData(response);
          if (data['error'] == 'name_exists!') {
            messageWarning('Нэр бүртгэлтэй байна!');
          } else {
            messageWarning('Алдаа гарлаа!');
          }
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
      var body = {
        "name": name,
        "rn": rn,
        "email": email,
        "phone": phone,
        "phone2": phone2,
        "phone3": phone3,
        "note": note,
        "lat": lat,
        "lng": lng
      };
      await Provider.of<HomeProvider>(context, listen: false).getPosition();
      final response = await api(Api.patch, 'seller/customer/$id/', body: body);
      if (response!.statusCode == 200) {
        messageComplete('Амжилттай засагдлаа.');
      } else {
        final data = convertData(response);
        if (data['error'] == 'name_exists!') {
          messageWarning('Нэр бүртгэлтэй байна!');
        } else {
          messageWarning('Алдаа гарлаа!');
        }
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  void setZone(Zone zone) {
    if (selectedZone != zone) {
      selectedZone = zone;
    } else {
      selectedZone = Zone(id: -1, name: 'Бүс сонгох');
    }
    notifyListeners();
  }

  Future getZones() async {
    try {
      final response = await api(Api.get, 'seller/get_delivery_zones/');
      if (response == null) return;
      if (response.statusCode == 200) {
        final data = convertData(response);
        zones = (data as List).map((z) => Zone.fromJson(z)).toList();
        notifyListeners();
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
      loanLimit: parseDouble(json['loan_limit']),
      loanLimitUse: json['loan_limit_use'],
      loanBalBlock: json['loan_bal_block'],
      custType: List<Map<String, dynamic>>.from(json['cust_type']),
    );
  }
}
