import 'package:pharmo_app/application/application.dart';
import 'package:pharmo_app/authentication/authentication/auth_error.dart';
import 'package:pharmo_app/views/SELLER/customer/customer_searcher.dart';
import 'package:pharmo_app/views/SELLER/customer/customer_tile.dart';

class CustomerList extends StatefulWidget {
  const CustomerList({super.key});

  @override
  State<CustomerList> createState() => _CustomerListState();
}

class _CustomerListState extends State<CustomerList> with SingleTickerProviderStateMixin {
  late AnimationController controller;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..repeat(reverse: true);

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
    await LoadingService.run(() async {
      final pp = context.read<PharmProvider>();
      await pp.fetchCustomers();
      await pp.getZones();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<HomeProvider, PharmProvider>(
      builder: (_, home, pp, child) {
        final user = Authenticator.security;
        if (user == null) return AuthError();
        return SafeArea(
          child: Column(
            spacing: 10,
            children: [
              CustomerSearcher(),
              customersList(pp),
            ],
          ).paddingSymmetric(horizontal: 10),
        );
      },
    );
  }

  Widget customersList(PharmProvider pp) {
    return Expanded(
      child: RefreshIndicator.adaptive(
        onRefresh: () async => init(),
        child: ListView.builder(
          controller: _scrollController,
          itemCount: pp.filteredCustomers.length + 1,
          itemBuilder: (context, ind) {
            if (ind == pp.filteredCustomers.length) {
              return _footer(pp);
            }
            return CustomerTile(customer: pp.filteredCustomers[ind]);
          },
        ),
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
