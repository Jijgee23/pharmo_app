import 'package:flutter/material.dart';
import 'package:pharmo_app/controllers/home_provider.dart';
import 'package:pharmo_app/controllers/pharms_provider.dart';
import 'package:pharmo_app/utilities/colors.dart';
import 'package:pharmo_app/utilities/sizes.dart';
import 'package:pharmo_app/utilities/utils.dart';
import 'package:pharmo_app/views/seller/customer/customer_details_paga.dart';
import 'package:pharmo_app/widgets/bottomSheet/my_sheet.dart';
import 'package:pharmo_app/widgets/dialog_and_messages/snack_message.dart';
import 'package:pharmo_app/widgets/inputs/custom_button.dart';
import 'package:pharmo_app/widgets/others/no_items.dart';
import 'package:pharmo_app/widgets/ui_help/container.dart';
import 'package:provider/provider.dart';

class CustomerList extends StatefulWidget {
  const CustomerList({super.key});

  @override
  State<CustomerList> createState() => _CustomerListState();
}

class _CustomerListState extends State<CustomerList> {
  late HomeProvider homeProvider;
  late PharmProvider pharmProvider;
  String selectedFilter = 'Нэрээр';
  String filter = 'name';
  TextInputType selectedType = TextInputType.name;
  setFilter(v) {
    setState(
      () {
        selectedFilter = v;
        if (v == 'Нэрээр') {
          filter = 'name';
          selectedType = TextInputType.text;
        } else if (v == 'Утасны дугаараар') {
          filter = 'phone';
          selectedType = TextInputType.number;
        } else {
          filter = 'rn';
          selectedType = TextInputType.text;
        }
      },
    );
  }

  List<String> filters = ['Нэрээр', 'Утасны дугаараар', 'Регистрийн дугаараар'];
  @override
  void initState() {
    super.initState();
    homeProvider = Provider.of<HomeProvider>(context, listen: false);
    pharmProvider = Provider.of<PharmProvider>(context, listen: false);
    pharmProvider.getCustomers(1, 100, context);
    homeProvider.getPosition();
    setState(() => uid = homeProvider.userId);
  }

  @override
  void dispose() {
    super.dispose();
  }

  int uid = -1;

  @override
  Widget build(BuildContext context) {
    return Consumer2<HomeProvider, PharmProvider>(
      builder: (_, homeProvider, pp, child) {
        return Scaffold(
            body: Column(children: [_searchBar(pp), _customersList(pp)]));
      },
    );
  }

  // Хайлтын widget
  Widget _searchBar(PharmProvider pp) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(color: Theme.of(context).shadowColor, blurRadius: 5)
        ],
      ),
      margin: const EdgeInsets.symmetric(vertical: 5),
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Row(
        children: [
          Expanded(
            child: TextFormField(
              controller: controller,
              cursorColor: Colors.black,
              cursorHeight: 20,
              cursorWidth: .8,
              keyboardType: selectedType,
              onChanged: (value) => _onSearch(value, pp),
              decoration: _formStyle(),
            ),
          ),
          InkWell(
            onTap: () => _setFilter,
            child: const Icon(Icons.arrow_drop_down, color: Colors.blue),
          ),
        ],
      ),
    );
  }

  _formStyle() {
    return InputDecoration(
      border: InputBorder.none,
      focusedBorder: InputBorder.none,
      hintText: '$selectedFilter хайх',
      hintStyle: const TextStyle(
        color: Colors.black38,
        fontSize: 14,
      ),
    );
  }

  _setFilter() {
    showMenu(
      color: Colors.white,
      context: context,
      shadowColor: Colors.grey.shade500,
      position: const RelativeRect.fromLTRB(100, 100, 0, 0),
      items: [
        ...filters.map(
          (f) => PopupMenuItem(
              child: Text(
                f,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              ),
              onTap: () => setFilter(f)),
        )
      ],
    );
  }

  // Хайлтын функц
  void _onSearch(String value, PharmProvider pp) {
    WidgetsBinding.instance.addPostFrameCallback((cb) async {
      if (value.isEmpty) {
        await pharmProvider.getCustomers(1, 100, context);
      } else {
        await pp.filtCustomers(filter, controller.text, context);
      }
    });
  }

  // Харилцагчдын жагсаалт
  _customersList(PharmProvider pp) {
    return Expanded(
      child: SingleChildScrollView(
        child: Column(
          children: [
            addCusotmer(pp),
            if (pp.filteredCustomers.isNotEmpty)
              ...pp.filteredCustomers.map(
                (c) => _customerBuilder(homeProvider, c),
              ),
            if (pp.filteredCustomers.isEmpty) const NoItems(),
            const SizedBox(height: kTextTabBarHeight + 20)
          ],
        ),
      ),
    );
  }

  // Харилцагч
  Widget _customerBuilder(HomeProvider homeProvider, Customer c) {
    bool selected = c.id == homeProvider.selectedCustomerId;
    return Ctnr(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              InkWell(
                onTap: () => _onTabCustomer(c),
                child: AnimatedContainer(
                  duration: const Duration(seconds: 1),
                  padding: EdgeInsets.all(!selected ? 12 : 2),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.grey)),
                  child: selected
                      ? const Icon(Icons.check, color: Colors.green)
                      : const SizedBox(),
                ),
              ),
              SizedBox(width: Sizes.mediumFontSize),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  greyText(c.name!, selected ? AppColors.succesColor : grey600),
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
          InkWell(
            onTap: () => goto(CustomerDetailsPage(customer: c)),
            child: Icon(
              Icons.chevron_right_rounded,
              color: Colors.blue.shade700,
            ),
          )
        ],
      ),
    );
  }

  TextStyle redText = TextStyle(
    color: Colors.red.shade600,
    fontSize: Sizes.smallFontSize,
    fontWeight: FontWeight.w400,
  );

  _onTabCustomer(Customer c) {
    if (c.rn != null) {
      homeProvider.changeSelectedCustomerId(c.id!);
      homeProvider.changeSelectedCustomerName(c.name!);
      // homeProvider.changeIndex(1);
    } else {
      message('Регистерийн дугааргүй харилцагч сонгох боломжгүй!');
    }
  }

  addCusotmer(PharmProvider pp) {
    return InkWell(
      onTap: () => registerCustomer(pp),
      child: Ctnr(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey)),
                child: const Icon(Icons.add, color: Colors.green)),
            const SizedBox(width: Sizes.mediumFontSize),
            greyText('Харилцагч бүртгэх', grey600),
          ],
        ),
      ),
    );
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

  final TextEditingController controller = TextEditingController();
  final TextEditingController name = TextEditingController();
  final TextEditingController rn = TextEditingController();
  final TextEditingController email = TextEditingController();
  final TextEditingController phone = TextEditingController();
  final TextEditingController phone2 = TextEditingController();
  final TextEditingController phone3 = TextEditingController();
  final TextEditingController note = TextEditingController();

  // Харилцгагч бүртгэх
  registerCustomer(PharmProvider pp) {
    final formKey = GlobalKey<FormState>();
    mySheet(
      title: 'Харилцагч бүртгэх',
      children: [
        Form(
          key: formKey,
          child: Wrap(
            runSpacing: Sizes.smallFontSize,
            children: [
              input('Нэр', name, null),
              input('Регистрийн дугаар', rn, null),
              input('И-Мейл', email, null),
              input('Утас', phone,
                  const TextInputType.numberWithOptions(signed: true)),
              const Text('Заавал биш',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.black54)),
              input('Нэмэлт тайлбар ', note, null),
              CustomButton(
                  text: 'Бүртгэх',
                  ontap: () async => await _registerCustomer(pp)),
            ],
          ),
        ),
      ],
    );
  }

  // Бүртгэх
  _registerCustomer(PharmProvider pp) async {
    if (name.text.isEmpty ||
        rn.text.isEmpty ||
        email.text.isEmpty ||
        phone.text.isEmpty) {
      message('Бүртгэл гүйцээнээ үү!');
    } else {
      await pp
          .registerCustomer(
        name.text,
        rn.text,
        email.text,
        phone.text,
        note.text,
        homeProvider.currentLatitude.toString(),
        homeProvider.currentLongitude.toString(),
        context,
      )
          .whenComplete(() {
        pp.getCustomers(1, 100, context);
        popSheet();
      });
    }
  }

  popSheet() {
    name.clear();
    phone.clear();
    note.clear();
    email.clear();
    rn.clear();
    phone2.clear();
    phone3.clear();
    note.clear();
    Navigator.pop(context);
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
// comment

class InputField extends StatelessWidget {
  final String hint;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;

  const InputField({
    super.key,
    required this.hint,
    required this.controller,
    this.validator,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration:
          BoxDecoration(color: card, borderRadius: BorderRadius.circular(20)),
      child: Row(
        children: [
          Expanded(
            child: TextFormField(
              controller: controller,
              cursorColor: Colors.black,
              cursorHeight: 20,
              style: const TextStyle(fontSize: 12.0),
              cursorWidth: .8,
              keyboardType: keyboardType,
              textInputAction: TextInputAction.done,
              validator: validator,
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
}
