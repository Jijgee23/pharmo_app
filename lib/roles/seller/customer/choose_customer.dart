import 'package:pharmo_app/application/application.dart';
import 'package:pharmo_app/roles/seller/customer/customer_listing.dart';

class ChooseCustomer extends StatefulWidget {
  const ChooseCustomer({super.key});

  @override
  State<ChooseCustomer> createState() => _ChooseCustomerState();
}

class _ChooseCustomerState extends State<ChooseCustomer> {
  final TextEditingController query = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  String selectedFilter = 'Нэрээр';
  String filter = 'name';

  final List<String> filters = [
    'Нэрээр',
    'Утасны дугаараар',
    'Регистрийн дугаараар'
  ];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    // Starts fresh on every open, in its own list: the customers tab keeps
    // whatever it was showing.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _listing.reset();
      _listing.search();
    });
  }

  @override
  void dispose() {
    query.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _listing.fetchMore();
    }
  }

  CustomerListing get _listing => context.read<PharmProvider>().pickerCustomers;

  void setFilter(String v) {
    setState(() {
      selectedFilter = v;
      filter =
          v == 'Нэрээр' ? 'name' : (v == 'Утасны дугаараар' ? 'phone' : 'rn');
    });
    // Re-run a search already typed, now matched by the new type.
    if (query.text.trim().isNotEmpty) _listing.search(type: filter);
  }

  void _onSearch(String v) {
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _listing.search(type: filter, value: v),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PharmProvider>(
      builder: (context, provider, _) => Scaffold(
        appBar: AppBar(
          titleSpacing: 0,
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          ),
          title: Padding(
            padding: const EdgeInsets.only(right: 16),
            child: ModernField(
              controller: query,
              onChanged: _onSearch,
              hint: '$selectedFilter хайх',
              suffixIcon: IconButton(
                icon: const Icon(Icons.tune_rounded, size: 18),
                onPressed: _showFilterMenu,
              ),
            ),
          ),
        ),
        body: Column(
          children: [
            // Active filter badge
            if (selectedFilter != 'Нэрээр')
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: const Color(0xFF00897B).withOpacity(0.06),
                child: Row(
                  spacing: 6,
                  children: [
                    Icon(Icons.filter_alt_outlined,
                        size: 14, color: const Color(0xFF00897B)),
                    Text(
                      selectedFilter,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF00897B),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            Expanded(
              child: provider.pickerCustomers.items.isEmpty &&
                      !provider.pickerCustomers.fetchingMore
                  ? _emptyState()
                  : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                      itemCount: provider.pickerCustomers.items.length + 1,
                      itemBuilder: (context, index) {
                        final listing = provider.pickerCustomers;
                        if (index == listing.items.length) {
                          return _footer(listing);
                        }
                        return _customerItem(listing.items[index]);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _customerItem(Customer e) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.white,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Color(0xFFEBF2F1)),
        ),
        child: ListTile(
          onTap: () => Navigator.pop(context, e),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          leading: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: const Color(0xFF00897B).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                (e.name ?? '?').substring(0, 1).toUpperCase(),
                style: const TextStyle(
                  color: Color(0xFF00897B),
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
            ),
          ),
          title: Text(
            e.name ?? '',
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          ),
          subtitle: Text(
            'РД: ${e.rn ?? "-"}',
            style: const TextStyle(color: Color(0xFF6B8280), fontSize: 12),
          ),
          trailing: const Icon(Icons.chevron_right_rounded,
              color: Color(0xFFD0DCDB), size: 20),
        ),
      ),
    );
  }

  Widget _footer(CustomerListing listing) {
    if (listing.fetchingMore) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Center(child: CircularProgressIndicator.adaptive()),
      );
    }
    if (!listing.hasMore && listing.items.isNotEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Center(
          child: Text(
            'Нийт ${listing.totalCount} харилцагч',
            style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _emptyState() {
    return const EmptyState(
      icon: Icons.person_search_rounded,
      title: 'Харилцагч олдсонгүй',
      message: 'Хайлтын утга эсвэл төрлөө өөрчлөөд дахин оролдоно уу.',
    );
  }

  void _showFilterMenu() {
    mySheet(
      title: 'Хайлтын төрөл сонгоно уу',
      children: filters
          .map((e) => SelectedFilter(
                selected: selectedFilter == e,
                caption: e,
                onSelect: () => setFilter(e),
              ))
          .toList(),
    );
  }
}
