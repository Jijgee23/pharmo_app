import 'package:flutter/material.dart';
import 'package:pharmo_app/controllers/home_provider.dart';
import 'package:pharmo_app/models/customer.dart';
import 'package:pharmo_app/controllers/pharms_provider.dart';
import 'package:pharmo_app/utilities/colors.dart';
import 'package:pharmo_app/utilities/utils.dart';
import 'package:pharmo_app/views/seller/customer_details_paga.dart';
import 'package:pharmo_app/widgets/indicator/pharmo_indicator.dart';
import 'package:pharmo_app/widgets/loader/data_screen.dart';
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
    init();
  }

  Future init() async {
    final homeProvider = context.read<HomeProvider>();
    try {
      homeProvider.setLoading(true);
      final pharmProvider = context.read<PharmProvider>();
      if (homeProvider.currentLatitude != null &&
              homeProvider.currentLongitude != null ||
          pharmProvider.filteredCustomers.isNotEmpty ||
          pharmProvider.zones.isNotEmpty) {
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
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<HomeProvider, PharmProvider>(
      builder: (_, homeProvider, pp, child) {
        return DataScreen(
          onRefresh: () async => init(),
          loading: homeProvider.loading,
          empty: pp.filteredCustomers.isEmpty,
          customLoading: shimmer(),
          child: homeProvider.loading
              ? PharmoIndicator()
              : _customersList(pp, homeProvider),
        );
      },
    );
  }

  // Харилцагчдын жагсаалт
  _customersList(PharmProvider pp, HomeProvider homeProvider) {
    return SingleChildScrollView(
      child: Column(
        children: [
          ...pp.filteredCustomers.map((cust) {
            return _customerBuilder(homeProvider, cust);
          }),
          SizedBox(height: 100),
        ],
      ),
    );
  }

  shimmer() {
    List<int> list = List.generate(10, (index) => index);
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        spacing: 10,
        children: list
            .map((ri) => ShimmerBox(controller: controller, height: 50))
            .toList(),
      ),
    );
  }

  // Харилцагч
  Widget _customerBuilder(HomeProvider homeProvider, Customer c) {
    bool selected = c.id == homeProvider.selectedCustomerId;
    return Card(
      color: white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: selected ? Colors.green : Colors.grey.shade400),
        borderRadius: BorderRadius.circular(10),
      ),
      child: InkWell(
        onTap: () => goto(CustomerDetailsPage(customer: c)),
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: EdgeInsets.all(15.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  spacing: 20,
                  children: [
                    InkWell(
                      onTap: () => _onTabCustomer(c, homeProvider),
                      child: Icon(
                        selected
                            ? Icons.check_box
                            : Icons.check_box_outline_blank,
                        color: selected ? Colors.green : Colors.grey,
                        size: 30,
                      ),
                    ),
                    Column(
                      spacing: 5,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        greyText(
                            c.name!, selected ? AppColors.succesColor : black),
                        if (c.rn != null)
                          greyText(
                              c.rn!, selected ? AppColors.succesColor : black),
                        if (c.loanBlock == true)
                          Text('Харилцагч дээр захиалга зээлээр өгөхгүй!',
                              style: redText),
                        if (c.location == false)
                          Text('Байршил тодорхойгүй', style: redText)
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: frenchGrey,
              )
            ],
          ),
        ),
      ),
    );
  }

  TextStyle redText = const TextStyle(
    color: Colors.red,
    fontSize: 12,
    fontWeight: FontWeight.w400,
  );

  void _onTabCustomer(Customer c, HomeProvider homeProvider) {
    if (c.id == homeProvider.selectedCustomerId) {
      homeProvider.changeSelectedCustomerId(0);
      homeProvider.changeSelectedCustomerName('');
    } else {
      homeProvider.changeSelectedCustomerId(c.id!);
      homeProvider.changeSelectedCustomerName(c.name!);
    }
  }

  Text greyText(String t, Color? color) {
    return Text(
      t,
      style: TextStyle(
        color: color ?? black,
        fontSize: 14,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}

// TextField
Widget input(String hint, TextEditingController contr, TextInputType? keyType) {
  return Container(
    decoration: BoxDecoration(
      color: card,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Row(
      children: [
        Expanded(
          child: TextFormField(
            controller: contr,
            cursorColor: Colors.black,
            cursorHeight: 20,
            style: const TextStyle(fontSize: 12.0),
            cursorWidth: .8,
            keyboardType: keyType,
            textInputAction: TextInputAction.done,
            decoration: InputDecoration(
              border: InputBorder.none,
              focusedBorder: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 20),
              hintText: hint,
              hintStyle: const TextStyle(
                color: Colors.black38,
              ),
            ),
          ),
        ),
      ],
    ),
  );
}
