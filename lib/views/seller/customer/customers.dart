import 'package:pharmo_app/views/SELLER/customer/customer_searcher.dart';
import 'package:pharmo_app/views/SELLER/customer/customer_tile.dart';
import 'package:pharmo_app/application/application.dart';
import 'package:pharmo_app/authentication/authentication/auth_error.dart';

class CustomerList extends StatefulWidget {
  const CustomerList({super.key});

  @override
  State<CustomerList> createState() => _CustomerListState();
}

class _CustomerListState extends State<CustomerList>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..repeat(reverse: true);
    Future.microtask(() => init(false));
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void init(bool force) async {
    await LoadingService.run(() async {
      final pharmProvider = context.read<PharmProvider>();
      await await pharmProvider.getCustomers(1, 100, context);
      await pharmProvider.getZones();
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
              customersList(pp, home),
            ],
          ).paddingSymmetric(horizontal: 10),
        );
      },
    );
  }

  Widget customersList(PharmProvider pp, HomeProvider homeProvider) {
    return Expanded(
      child: RefreshIndicator.adaptive(
        onRefresh: () async => init(true),
        child: ListView.builder(
          itemCount: pp.filteredCustomers.length,
          itemBuilder: (context, ind) {
            final customer = pp.filteredCustomers[ind];
            return CustomerTile(customer: customer);
          },
        ),
      ),
    );
  }

  shimmer() {
    List<int> list = List.generate(10, (index) => index);
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.all(10),
      child: Column(
        spacing: 10,
        children: list
            .map((ri) => ShimmerBox(controller: controller, height: 50))
            .toList(),
      ),
    );
  }
}
