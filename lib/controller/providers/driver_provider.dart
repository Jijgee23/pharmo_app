import 'package:geolocator/geolocator.dart';
import 'package:pharmo_app/controller/models/delivery.dart';
import 'package:pharmo_app/application/application.dart';

class DriverProvider extends ChangeNotifier {
  late LocationPermission permission;

  List<Zone> zones = [];
  List<Order> orders = [];
  List<Delman> delmans = [];
  List<Delivery> history = <Delivery>[];

  void reset() {
    zones.clear();
    orders.clear();
    delmans.clear();
    history.clear();
    notifyListeners();
  }

  Future<dynamic> getOrders() async {
    try {
      final r = await api(Api.get, 'delivery/allocation/');
      if (r == null) return;
      if (r.statusCode == 200) {
        final data = jsonDecode(utf8.decode(r.bodyBytes));
        print(data);
        orders = (data as List).map((e) => Order.fromJson(e)).toList();
        orders.sort((a, b) => a.orderer!.name.compareTo(b.orderer!.name));
        notifyListeners();
      }
    } catch (e) {
      debugPrint(e.toString());
    }
    notifyListeners();
  }

  Future addOrdersToDelivery(List<int> ords) async {
    try {
      if (ords.isEmpty) {
        messageWarning('Захиалга сонгоно уу!');
        return;
      }

      print('Orders being sent: $ords');
      final body = {"order_ids": ords.map((id) => id.toString()).toList()};
      final url = 'delivery/add_to_delivery/';
      final r = await api(Api.patch, url, body: body);
      if (r == null) {
        messageWarning('Сервертэй холбогдож чадсангүй!');
        return;
      }
      if (r.statusCode == 200 || r.statusCode == 201) {
        await getOrders();
        HomeProvider home =
            Provider.of<HomeProvider>(Get.context!, listen: false);
        home.changeIndex(0);
        messageComplete('Амжилттай нэмэгдлээ');
      } else {
        messageWarning('Захиалгуудыг түгээлтэд нэмэхэд алдаа гарлаа!');
      }
    } catch (e) {
      debugPrint('API Error: $e');
      messageWarning('Сервертэй холбогдоход алдаа гарлаа!');
    }
    notifyListeners();
  }

  Future<dynamic> passOrdersToDelman(List<int> ords, int delId) async {
    try {
      if (ords.isEmpty) {
        messageWarning('Захиалга сонгоно уу!');
        return;
      }
      print('delivery man id: $delId');

      print('Orders being sent: $ords');
      final body = {"order_ids": ords, "delman_id": delId};

      final r = await api(Api.patch, 'delivery/pass_drops/', body: body);

      if (r == null) {
        messageWarning('Сервертэй холбогдож чадсангүй!');
        return;
      }

      if (r.statusCode == 200 || r.statusCode == 201) {
        await getOrders();
        messageWarning('Амжилттай нэмэгдлээ');
      } else {
        print(ords.length);
        messageWarning(
            '${ords.length == 1 ? 'Захиалгыг' : 'Захиалгуудыг'} дамжуулахад алдаа гарлаа!');
      }
    } catch (e) {
      debugPrint('API Error: $e');
      messageError('Сервертэй холбогдоход алдаа гарлаа!');
    }
    notifyListeners();
  }

  getDelmans() async {
    try {
      final r = await api(Api.get, 'delivery/delmans/');
      if (r == null) return;
      if (r.statusCode == 200) {
        final data = jsonDecode(utf8.decode(r.bodyBytes));
        delmans = (data as List).map((del) => Delman.fromJson(del)).toList();
        notifyListeners();
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  getShipmentHistory({DateTimeRange? range}) async {
    try {
      String url;

      if (range != null) {
        String date1 = range.start.toString().substring(0, 10);
        String date2 = range.end.toString().substring(0, 10);
        url = 'delivery/history/?start=$date1&end=$date2';
      } else {
        url = "delivery/history/";
      }
      final r = await api(Api.get, url);
      if (r == null) return;
      if (r.statusCode == 200) {
        final data = convertData(r);
        print(data);
        List<dynamic> ships = data['results'];
        history = (ships).map((e) => Delivery.fromJson(e)).toList();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Алдаа гарлаа: ${e.toString()}');
    }
  }
}
