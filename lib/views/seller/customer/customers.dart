import 'package:flutter/material.dart';
import 'package:pharmo_app/controller/providers/home_provider.dart';
import 'package:pharmo_app/controller/providers/pharms_provider.dart';
import 'package:pharmo_app/views/seller/customer/customer_tile.dart';
import 'package:pharmo_app/widgets/loader/shimmer_box.dart';
import 'package:provider/provider.dart';

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
    init(false);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future init(bool force) async {
    final homeProvider = context.read<HomeProvider>();
    try {
      homeProvider.setLoading(true);
      final pharmProvider = context.read<PharmProvider>();
      if (homeProvider.currentLatitude != null &&
              homeProvider.currentLongitude != null ||
          pharmProvider.filteredCustomers.isNotEmpty ||
          pharmProvider.zones.isNotEmpty && !force) {
        return;
      }
      await pharmProvider.getCustomers(1, 100, context);
      await homeProvider.getPosition();
      await pharmProvider.getZones();
    } catch (e) {
      throw Exception(e);
    } finally {
      homeProvider.setLoading(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<HomeProvider, PharmProvider>(
      builder: (_, homeProvider, pp, child) {
        return SafeArea(
          child: RefreshIndicator(
            onRefresh: () async => await init(true),
            child: customersList(pp, homeProvider),
          ),
        );
      },
    );
  }

  ListView customersList(PharmProvider pp, HomeProvider homeProvider) {
    return ListView.builder(
      padding: EdgeInsets.all(5),
      itemCount: pp.filteredCustomers.length,
      itemBuilder: (context, ind) {
        final customer = pp.filteredCustomers[ind];
        return CustomerTile(customer: customer);
      },
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
