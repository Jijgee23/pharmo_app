import 'package:geolocator/geolocator.dart';
import 'package:pharmo_app/application/application.dart';
import 'package:pharmo_app/roles/driver/delivery_history/delivery_history_filter.dart';

class DriverProvider extends ChangeNotifier {
  late LocationPermission permission;

  List<Zone> zones = [];
  List<DeliveryOrder> orders = [];
  List<Delman> delmans = [];
  List<Delivery> history = <Delivery>[];

  void reset() {
    zones.clear();
    orders.clear();
    ordersLoaded = false;
    ordersFailed = false;
    ordersRefreshing = false;
    delmans.clear();
    history.clear();
    historyFilter = const DeliveryHistoryFilter();
    historyTotal = 0;
    _historyPage = 0;
    historyScrollOffset = 0;
    notifyListeners();
  }

  /// The first fetch of the ready orders has come back (either way).
  bool ordersLoaded = false;

  /// The last fetch failed, so [orders] may be out of date or missing.
  bool ordersFailed = false;

  /// A refresh someone asked for is under way; the quiet ones (after
  /// adding or passing orders, pull-to-refresh) don't set it.
  bool ordersRefreshing = false;

  /// [getOrders], shown as loading while it runs; true once done.
  Future<bool> refreshOrders() async {
    if (ordersRefreshing) return false;
    ordersRefreshing = true;
    notifyListeners();
    try {
      return await getOrders();
    } finally {
      ordersRefreshing = false;
      notifyListeners();
    }
  }

  /// The orders ready to go out (GET delivery/allocation/). True once they
  /// are known, even when there are none.
  Future<bool> getOrders() async {
    try {
      final r = await api(Api.get, 'delivery/allocation/');
      if (r == null || r.statusCode != 200) {
        ordersFailed = true;
        return false;
      }
      final data = convertData(r);
      orders = (data as List).map((e) => DeliveryOrder.fromJson(e)).toList();
      orders.sort((a, b) => a.recipientName.compareTo(b.recipientName));
      ordersFailed = false;
      return true;
    } catch (e) {
      debugPrint('getOrders: $e');
      ordersFailed = true;
      return false;
    } finally {
      ordersLoaded = true;
      notifyListeners();
    }
  }

  /// Puts ready orders on the caller's own active delivery, creating it if
  /// need be (PATCH delivery/add_to_delivery/). True once they are on it.
  Future<bool> addOrdersToDelivery(List<int> orderIds) async {
    if (!await _takeOrders(orderIds)) return false;
    await getOrders();
    _showOwnDelivery();
    messageComplete('Түгээлтэд нэмэгдлээ');
    return true;
  }

  /// Hands ready orders to another deliveryman. True once they are off the
  /// ready list, even if they got no further than the caller's delivery.
  ///
  /// A deliveryman passes drops only from their own active delivery
  /// (PATCH delivery/pass_drops/ answers "No orders to pass!" for ready
  /// orders), and add_to_delivery/ answers "Delman not found!" to a
  /// delman_id, so the orders go onto the caller's delivery first and are
  /// passed on from there.
  Future<bool> passOrdersToDelman(List<int> orderIds, int delmanId) async {
    if (!await _takeOrders(orderIds)) return false;
    final error = await _patch('delivery/pass_drops/', {
      'order_ids': orderIds,
      'delman_id': delmanId,
    });
    await getOrders();
    if (error == null) {
      messageComplete('Түгээгчид шилжүүллээ');
    } else {
      // Stuck on the caller's delivery: show it to them.
      _showOwnDelivery();
      messageWarning(
          'Захиалгууд таны түгээлтэд нэмэгдсэн ч шилжүүлж чадсангүй: ${passErrorMessage(error)}');
    }
    return true;
  }

  /// Passes orders on the caller's active delivery to [delmanId]'s active
  /// delivery (PATCH delivery/pass_drops/). True once they are passed; the
  /// caller refreshes the delivery.
  Future<bool> passDrops(List<int> orderIds, int delmanId) async {
    if (orderIds.isEmpty) {
      messageWarning('Захиалга сонгоно уу!');
      return false;
    }
    final error = await _patch('delivery/pass_drops/', {
      'order_ids': orderIds,
      'delman_id': delmanId,
    });
    if (error == null) {
      messageComplete('Түгээгчид шилжүүллээ');
      return true;
    }
    messageWarning(passErrorMessage(error));
    return false;
  }

  /// What to tell the driver when pass_drops/ refuses with [error]: it
  /// answers in English, so the cases it documents are put in Mongolian.
  static String passErrorMessage(Object error) {
    final text = apiErrorMessage(error) ?? '';
    final lower = text.toLowerCase();
    if (lower.contains('no orders to pass')) {
      return 'Шилжүүлэх захиалга алга: хүргэгдсэн, эсвэл таны түгээлтэд байхгүй байна.';
    }
    if (lower.contains('active')) return 'Сонгосон түгээгчид идэвхтэй түгээлт алга.';
    if (lower.contains('delman not found')) return 'Түгээгч олдсонгүй.';
    return text.isEmpty ? 'Шилжүүлэхэд алдаа гарлаа!' : text;
  }

  // Onto the map, where the caller's delivery is.
  void _showOwnDelivery() => Get.context?.read<HomeProvider>().changeIndex(0);

  // add_to_delivery/ onto the caller's own delivery; warns and returns
  // false if the orders didn't go on.
  Future<bool> _takeOrders(List<int> orderIds) async {
    if (orderIds.isEmpty) {
      messageWarning('Захиалга сонгоно уу!');
      return false;
    }
    final error = await _patch('delivery/add_to_delivery/', {'order_ids': orderIds});
    if (error == null) return true;
    if (error is Map && error.containsKey('no_orders')) {
      // Taken meanwhile, most likely by another deliveryman: show what's left.
      messageWarning('Сонгосон захиалгууд өөр түгээлтэд орсон байна. Жагсаалтыг шинэчиллээ.');
      await getOrders();
    } else {
      messageWarning(apiErrorMessage(error) ?? 'Захиалгуудыг түгээлтэд нэмэхэд алдаа гарлаа!');
    }
    return false;
  }

  // PATCHes [body] to [endpoint]: null once done, else the error body (or a
  // message of its own when the server couldn't be reached).
  Future<Object?> _patch(String endpoint, Map<String, dynamic> body) async {
    try {
      final r = await api(Api.patch, endpoint, body: body);
      if (r == null) return 'Сервертэй холбогдож чадсангүй!';
      if (r.statusCode == 200 || r.statusCode == 201) return null;
      return apiBody(r) ?? 'Алдаа гарлаа (${r.statusCode})';
    } catch (e) {
      debugPrint('API Error: $e');
      return 'Сервертэй холбогдоход алдаа гарлаа!';
    }
  }

  /// Every deliveryman but the caller, to hand orders to.
  List<Delman> get otherDelmans {
    final me = Authenticator.security?.id;
    return delmans.where((d) => d.id != me).toList();
  }

  Future<void> getDelmans() async {
    try {
      final r = await api(Api.get, 'delivery/delmans/');
      if (r == null) return;
      if (r.statusCode == 200) {
        final data = convertData(r);
        delmans = (data as List).map((del) => Delman.fromJson(del)).toList();
        notifyListeners();
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  // Delivery history (GET delivery/history/): filtered, newest first by
  // default, a page at a time.

  /// Applied by every history fetch, so a refresh keeps the filters.
  DeliveryHistoryFilter historyFilter = const DeliveryHistoryFilter();
  int historyTotal = 0;
  int _historyPage = 0;
  bool historyLoading = false;
  bool historyFetchingMore = false;

  bool get historyHasMore => history.length < historyTotal;

  /// Whether a first page has come in.
  bool get historyLoaded => _historyPage > 0;

  /// Where the history tab's list was scrolled to when last left.
  double historyScrollOffset = 0;

  /// Reloads the history if it has been shown, for a delivery just ended.
  Future<void> refreshHistory() async {
    if (historyLoaded) await loadHistory();
  }

  // Bumped per reload: a page arriving for an older filter is dropped.
  int _historyRequest = 0;

  /// Sets [filter] without fetching, for a change that can't alter the
  /// result (the search type while the search box is empty).
  void setHistoryFilter(DeliveryHistoryFilter filter) {
    historyFilter = filter;
    notifyListeners();
  }

  /// Sets [filter] and loads its first page.
  Future<void> applyHistoryFilter(DeliveryHistoryFilter filter) async {
    historyFilter = filter;
    await loadHistory();
  }

  /// The first page with [historyFilter], replacing the list.
  Future<void> loadHistory() async {
    final request = ++_historyRequest;
    historyLoading = true;
    // A "more" still on its way belongs to the old list and gets dropped.
    historyFetchingMore = false;
    notifyListeners();
    final page = await _fetchHistoryPage(request, 1);
    if (request != _historyRequest) return;
    historyLoading = false;
    if (page != null) {
      history = page.$1;
      historyTotal = page.$2;
      _historyPage = 1;
    }
    notifyListeners();
  }

  /// The next page, appended, if there is one and none is on its way.
  Future<void> loadMoreHistory() async {
    if (historyLoading || historyFetchingMore || !historyHasMore) return;
    final request = _historyRequest;
    historyFetchingMore = true;
    notifyListeners();
    final page = await _fetchHistoryPage(request, _historyPage + 1);
    if (request != _historyRequest) return;
    historyFetchingMore = false;
    if (page != null) {
      history.addAll(page.$1);
      historyTotal = page.$2;
      _historyPage++;
    }
    notifyListeners();
  }

  // One page of history, or null if it couldn't be had.
  Future<(List<Delivery>, int)?> _fetchHistoryPage(int request, int page) async {
    try {
      final endpoint = Uri(
        path: 'delivery/history/',
        queryParameters: {...historyFilter.toQuery(), 'page': '$page'},
      ).toString();
      final r = await api(Api.get, endpoint);
      if (r == null || r.statusCode != 200) return null;
      final data = convertData(r);
      final List<dynamic> ships = data['results'] ?? [];
      return (ships.map((e) => Delivery.fromJson(e)).toList(), (data['count'] ?? 0) as int);
    } catch (e) {
      debugPrint('Алдаа гарлаа: ${e.toString()}');
      return null;
    }
  }

  /// The zones a delivery can cover (GET delivery/zone/, readable by D/VS),
  /// for the history's zone filter.
  Future<void> getDeliveryZones() async {
    try {
      final r = await api(Api.get, 'delivery/zone/');
      if (r == null || r.statusCode != 200) return;
      zones = (convertData(r) as List).map((z) => Zone.fromJson(z)).toList();
      notifyListeners();
    } catch (e) {
      debugPrint(e.toString());
    }
  }
}
