import 'package:pharmo_app/application/application.dart';
import 'package:pharmo_app/authentication/authentication/auth_error.dart';
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
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;

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

    _scrollController.addListener(_onScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) async => await init());
  }

  @override
  void dispose() {
    controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      context.read<PharmProvider>().fetchMoreCustomers();
    }
  }

  Future init() async {
    setState(() => _isLoading = true);
    final pp = context.read<PharmProvider>();
    await pp.fetchCustomers();
    await pp.getZones();
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
          onRefresh: () async => init(),
          child: HomeScrollListener(
            xchild: Builder(builder: (context) {
              if (_isLoading) {
                return _buildSkeletonList();
              }
              return ListView.builder(
                controller: _scrollController,
                itemCount: pp.filteredCustomers.length + 1,
                itemBuilder: (context, ind) {
                  if (ind == pp.filteredCustomers.length) {
                    return _footer(pp);
                  }
                  return CustomerTile(customer: pp.filteredCustomers[ind]);
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

  Widget _footer(PharmProvider pp) {
    if (pp.fetchingMore) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Center(child: CircularProgressIndicator.adaptive()),
      );
    }
    if (!pp.hasMore && pp.filteredCustomers.isNotEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Center(
          child: Text(
            'Нийт ${pp.totalCount} харилцагч',
            style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }
}
