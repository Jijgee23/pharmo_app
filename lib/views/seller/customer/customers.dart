import 'package:flutter/material.dart';
import 'package:pharmo_app/controllers/home_provider.dart';
import 'package:pharmo_app/controllers/pharms_provider.dart';
import 'package:pharmo_app/utilities/colors.dart';
import 'package:pharmo_app/utilities/constants.dart';
import 'package:pharmo_app/utilities/sizes.dart';
import 'package:pharmo_app/utilities/utils.dart';
import 'package:pharmo_app/views/seller/customer/customer_details_paga.dart';
import 'package:pharmo_app/widgets/dialog_and_messages/snack_message.dart';
import 'package:pharmo_app/widgets/loader/data_screen.dart';
import 'package:provider/provider.dart';

class CustomerList extends StatefulWidget {
  const CustomerList({super.key});

  @override
  State<CustomerList> createState() => _CustomerListState();
}

class _CustomerListState extends State<CustomerList> {
  late HomeProvider homeProvider;
  late PharmProvider pharmProvider;
  @override
  void initState() {
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
      setState(() => uid = homeProvider.userId);
      setLoading(false);
    });
  }

  int uid = -1;
  bool loading = false;
  setLoading(bool n) {
    setState(() {
      loading = n;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<HomeProvider, PharmProvider>(
      builder: (_, homeProvider, pp, child) {
        return DataScreen(
          onRefresh: () async => init(),
          loading: loading,
          empty: pp.filteredCustomers.isEmpty,
          child: Column(
            children: [_customersList(pp)],
          ),
        );
      },
    );
  }

  // Харилцагчдын жагсаалт
  _customersList(PharmProvider pp) {
    return Expanded(
      child: ListView.builder(
        itemCount: pp.filteredCustomers.length,
        itemBuilder: (context, index) => _customerBuilder(
          homeProvider,
          pp.filteredCustomers[index],
        ),
      ),
    );
  }

  // Харилцагч
  Widget _customerBuilder(HomeProvider homeProvider, Customer c) {
    bool selected = c.id == homeProvider.selectedCustomerId;
    return InkWell(
      onTap: () => goto(CustomerDetailsPage(customer: c)),
      child: Container(
        padding: padding15,
        margin: EdgeInsets.only(bottom: Sizes.height * .008),
        decoration: BoxDecoration(color: primary.withOpacity(.15), borderRadius: border20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                InkWell(
                  onTap: () => _onTabCustomer(c),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 500),
                    padding: EdgeInsets.all(!selected ? 15 : 5),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      // border: Border.all(color: Colors.grey),
                    ),
                    child:
                        selected ? const Icon(Icons.check, color: Colors.green) : const SizedBox(),
                  ),
                ),
                const SizedBox(width: Sizes.mediumFontSize),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    greyText(c.name!, selected ? AppColors.succesColor : black),
                    if (c.loanBlock == true)
                      Text('Харилцагч дээр захиалга зээлээр өгөхгүй!', style: redText),
                    const SizedBox(width: 10),
                    if (c.location == false) Text('Байршил тодорхойгүй', style: redText)
                  ],
                ),
              ],
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: white,
            )
          ],
        ),
      ),
    );
  }

  TextStyle redText = const TextStyle(
    color: Colors.red,
    fontSize: Sizes.smallFontSize,
    fontWeight: FontWeight.w400,
  );

  _onTabCustomer(Customer c) {
    if (c.id == homeProvider.selectedCustomerId) {
      homeProvider.changeSelectedCustomerId(0);
      homeProvider.changeSelectedCustomerName('');
    } else {
      if (c.rn != null) {
        homeProvider.changeSelectedCustomerId(c.id!);
        homeProvider.changeSelectedCustomerName(c.name!);
        // homeProvider.changeIndex(1);
      } else {
        message('Регистерийн дугааргүй харилцагч сонгох боломжгүй!');
      }
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
