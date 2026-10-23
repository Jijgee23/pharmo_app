import 'package:pharmo_app/application/application.dart';
import 'package:pharmo_app/authentication/authentication/auth_error.dart';
import 'package:pharmo_app/roles/seller/customer/customer_listing.dart';
import 'package:pharmo_app/roles/seller/customer/customer_searcher.dart';
import 'package:pharmo_app/roles/seller/customer/customer_tile.dart';

class CustomerList extends StatefulWidget {
  const CustomerList({super.key});

  @override
  State<CustomerList> createState() => _CustomerListState();
}

class _CustomerListState extends State<CustomerList> with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late Animation<double> _shimmerAnimation;
  bool _isLoading = false;

  // This widget is rebuilt each time the bottom bar switches back to it;
  // the list, its search and scroll position are kept on PharmProvider.
  late final CustomerListing _listing;
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    _shimmerAnimation = Tween<double>(begin: 0.4, end: 0.85).animate(
      CurvedAnimation(parent: controller, curve: Curves.easeInOut),
    );

    _listing = context.read<PharmProvider>().customers;
    _scrollController = ScrollController(initialScrollOffset: _listing.scrollOffset)
      ..addListener(_onScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) async => await init());
  }

  @override
  void dispose() {
    controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final position = _scrollController.position;
    _listing.scrollOffset = position.pixels;
    if (position.pixels >= position.maxScrollExtent - 200) {
      _listing.fetchMore();
    }
  }

  Future init() async {
    final pp = context.read<PharmProvider>();
    // Back on the tab with a list already loaded: show it as it was.
    if (!_listing.loaded) await refresh();
    if (pp.zones.isEmpty) await pp.getZones();
  }

  // Page 1 again, keeping the search in effect.
  Future refresh() async {
    setState(() => _isLoading = true);
    await _listing.search();
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<HomeProvider, PharmProvider>(
      builder: (_, home, pp, child) {
        final user = Authenticator.security;
        if (user == null) return AuthError();
        return SafeArea(
          bottom: false,
          child: Column(
            spacing: 10,
            children: [
              if (context.isLandscape) SizedBox(height: 14),
              CustomerSearcher(),
              customersList(),
            ],
          ).paddingSymmetric(horizontal: 10),
        );
      },
    );
  }

  Widget customersList() {
    return Consumer2<PharmProvider, HomeProvider>(
      builder: (context, pp, home, child) => Expanded(
        child: RefreshIndicator.adaptive(
          onRefresh: refresh,
          child: HomeScrollListener(
            xchild: Builder(builder: (context) {
              final listing = pp.customers;
              if (_isLoading) {
                return _buildSkeletonList();
              }
              if (listing.items.isEmpty && !listing.fetchingMore) {
                return const EmptyState(
                  icon: Icons.person_search_rounded,
                  title: 'Харилцагч олдсонгүй',
                  message: 'Хайлтын утга эсвэл төрлөө өөрчлөөд дахин оролдоно уу.',
                  padding: EdgeInsets.only(bottom: 100),
                );
              }
              return ListView.builder(
                controller: _scrollController,
                itemCount: listing.items.length + 1,
                itemBuilder: (context, ind) {
                  if (ind == listing.items.length) {
                    return _footer(listing);
                  }
                  return CustomerTile(customer: listing.items[ind]);
                },
              );
            }),
          ),
        ),
      ),
    );
  }

  Widget _buildSkeletonList() {
    return AnimatedBuilder(
      animation: _shimmerAnimation,
      builder: (_, __) => ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 8,
        itemBuilder: (_, __) => _buildSkeletonTile(),
      ),
    );
  }

  Widget _buildSkeletonTile() {
    final color = Colors.grey.shade300.withOpacity(_shimmerAnimation.value);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 14,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 12,
                  width: 100,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4)),
          ),
        ],
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
            style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }
}
