import 'package:pharmo_app/application/application.dart';

/// One paged, searchable list of the seller's customers (GET
/// seller/customer/). The customers tab and the order sheet's customer
/// picker each own one, so searching in one leaves the other as it was.
class CustomerListing {
  CustomerListing(this._notify);

  /// Rebuilds whoever listens to the owning provider.
  final VoidCallback _notify;

  /// Search types, as sent to the API, and how the search box names them.
  static const searchTypes = {
    'name': 'Нэрээр',
    'phone': 'Утасны дугаараар',
    'rn': 'Регистрийн дугаараар',
  };

  static const _params = {
    'name': 'name__icontains',
    'phone': 'phone', // the API matches phones exactly
    'rn': 'rn__icontains',
  };

  static const pageSize = 30;

  final List<Customer> items = [];
  int page = 1;
  int totalCount = 0;
  bool hasMore = false;
  bool fetchingMore = false;

  /// A page has loaded since the last [search] or [reset]: the list can be
  /// shown as is, e.g. on returning to the customers tab.
  bool loaded = false;

  /// The search in effect: a [searchTypes] key and the text matched by it.
  String searchType = 'name';
  String searchValue = '';

  /// Last scroll position of the list showing this listing.
  double scrollOffset = 0;

  // Bumped by every search: a page arriving for an older one (typing
  // overtook it) is dropped instead of mixed into the newer results.
  int _request = 0;

  /// Loads page 1 for [value] matched by [type]; either defaults to the
  /// search already in effect.
  Future<void> search({String? type, String? value}) async {
    searchType = type ?? searchType;
    searchValue = value ?? searchValue;
    items.clear();
    page = 1;
    totalCount = 0;
    hasMore = false;
    loaded = false;
    scrollOffset = 0;
    await _load(++_request);
  }

  /// Appends the next page, if there is one and none is on its way.
  Future<void> fetchMore() async {
    if (!hasMore || fetchingMore) return;
    await _load(_request);
  }

  /// Back to an empty, unsearched list, e.g. on logout.
  void reset() {
    _request++;
    items.clear();
    page = 1;
    totalCount = 0;
    hasMore = false;
    fetchingMore = false;
    loaded = false;
    searchType = 'name';
    searchValue = '';
    scrollOffset = 0;
  }

  Future<void> _load(int request) async {
    fetchingMore = true;
    _notify();
    try {
      final text = searchValue.trim();
      final endpoint = Uri(
        path: 'seller/customer/',
        queryParameters: {
          if (text.isNotEmpty) _params[searchType]!: text,
          'page': '$page',
          'page_size': '$pageSize',
        },
      ).toString();
      final r = await api(Api.get, endpoint);
      if (r == null || request != _request) return;
      if (apiSucceess(r)) {
        final data = convertData(r) as Map;
        final List results = data['results'] ?? [];
        totalCount = data['count'] ?? 0;
        items.addAll(results.map((p) => Customer.fromJson(p)));
        hasMore = items.length < totalCount;
        if (hasMore) page++;
        loaded = true;
      } else {
        messageWarning('Алдаа гарлаа');
      }
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      // A superseded request leaves the flag to the one that replaced it.
      if (request == _request) {
        fetchingMore = false;
        _notify();
      }
    }
  }
}
