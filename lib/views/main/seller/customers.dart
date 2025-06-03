import 'package:flutter/material.dart';
import 'package:pharmo_app/controllers/home_provider.dart';
import 'package:pharmo_app/models/customer.dart';
import 'package:pharmo_app/controllers/pharms_provider.dart';
import 'package:pharmo_app/utilities/colors.dart';
import 'package:pharmo_app/utilities/sizes.dart';
import 'package:pharmo_app/utilities/utils.dart';
import 'package:pharmo_app/views/main/seller/customer_details_paga.dart';
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
  late HomeProvider homeProvider;
  late PharmProvider pharmProvider;
  late AnimationController controller;
  @override
  void initState() {
    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..repeat(reverse: true);
    super.initState();
    homeProvider = Provider.of<HomeProvider>(context, listen: false);
    pharmProvider = Provider.of<PharmProvider>(context, listen: false);
    init();
  }

  init() {
    WidgetsBinding.instance.addPostFrameCallback((cb) async {
      setLoading(true);
      await pharmProvider.getCustomers(1, 100, context);
      await homeProvider.getPosition();
      await pharmProvider.getZones();
      setLoading(false);
    });

    setState(() => uid = homeProvider.userId);
  }

  int uid = -1;
  bool loading = false;
  setLoading(bool n) {
    if (mounted) {
      setState(() {
        loading = n;
      });
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
          loading: loading,
          empty: pp.filteredCustomers.isEmpty,
          customLoading: shimmer(),
          pad: EdgeInsets.all(5.0),
          child: _customersList(pp),
        );
      },
    );
  }

  // Харилцагчдын жагсаалт
  _customersList(PharmProvider pp) {
    return ListView.separated(
      padding: EdgeInsets.only(top: 5.0),
      separatorBuilder: (context, index) => const SizedBox(height: 10.0),
      itemCount: pp.filteredCustomers.length,
      itemBuilder: (context, index) => _customerBuilder(
        homeProvider,
        pp.filteredCustomers[index],
      ),
    );
  }

  shimmer() {
    List<int> list = List.generate(10, (index) => index);
    return SingleChildScrollView(
      padding: EdgeInsets.all(10.0),
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
    return InkWell(
      onTap: () => goto(CustomerDetailsPage(customer: c)),
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: Sizes.height * .01,
          horizontal: Sizes.height * .01,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0),
          border: Border.all(color: grey300),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withAlpha(50),
              spreadRadius: 1,
              blurRadius: 3,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              spacing: 10,
              children: [
                InkWell(
                  onTap: () => _onTabCustomer(c),
                  child: Icon(
                    selected ? Icons.check_box : Icons.check_box_outline_blank,
                    color: selected ? Colors.green : Colors.grey,
                    size: Sizes.mediumFontSize * 2.2,
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    greyText(c.name!, selected ? AppColors.succesColor : black),
                    if (c.loanBlock == true)
                      Text('Харилцагч дээр захиалга зээлээр өгөхгүй!',
                          style: redText),
                    const SizedBox(width: 10),
                    if (c.location == false)
                      Text('Байршил тодорхойгүй', style: redText)
                  ],
                ),
              ],
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: frenchGrey,
            )
          ],
        ),
      ),
    );
  }

  TextStyle redText = const TextStyle(
    color: Colors.red,
    fontSize: 12,
    fontWeight: FontWeight.w400,
  );

  _onTabCustomer(Customer c) {
    if (c.id == homeProvider.selectedCustomerId) {
      homeProvider.changeSelectedCustomerId(0);
      homeProvider.changeSelectedCustomerName('');
    } else {
      homeProvider.changeSelectedCustomerId(c.id!);
      homeProvider.changeSelectedCustomerName(c.name!);
    }
  }

  greyText(String t, Color? color) {
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
