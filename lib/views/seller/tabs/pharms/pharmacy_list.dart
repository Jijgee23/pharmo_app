import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pharmo_app/controllers/home_provider.dart';
import 'package:pharmo_app/controllers/pharms_provider.dart';
import 'package:pharmo_app/utilities/colors.dart';
import 'package:pharmo_app/utilities/utils.dart';
import 'package:pharmo_app/utilities/varlidator.dart';
import 'package:pharmo_app/views/seller/tabs/pharms/customer_details_paga.dart';
import 'package:pharmo_app/widgets/dialog_and_messages/snack_message.dart';
import 'package:pharmo_app/widgets/inputs/custom_button.dart';
import 'package:provider/provider.dart';

class PharmacyList extends StatefulWidget {
  const PharmacyList({super.key});

  @override
  State<PharmacyList> createState() => _PharmacyListState();
}

class _PharmacyListState extends State<PharmacyList> {
  final TextEditingController controller = TextEditingController();
  final TextEditingController name = TextEditingController();
  final TextEditingController rn = TextEditingController();
  final TextEditingController email = TextEditingController();
  final TextEditingController phone = TextEditingController();
  final TextEditingController phone2 = TextEditingController();
  final TextEditingController phone3 = TextEditingController();
  final TextEditingController note = TextEditingController();
  late HomeProvider homeProvider;
  late PharmProvider pharmProvider;
  String selectedFilter = 'Нэрээр';
  String filter = 'name';
  TextInputType selectedType = TextInputType.name;
  setFilter(v) {
    setState(() {
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
    });
  }

  List<String> filters = ['Нэрээр', 'Утасны дугаараар', 'Регистрийн дугаараар'];
  @override
  void initState() {
    super.initState();
    homeProvider = Provider.of<HomeProvider>(context, listen: false);
    pharmProvider = Provider.of<PharmProvider>(context, listen: false);
    // pharmProvider.getPharmacyList();
    pharmProvider.getCustomers(1, 100, context);
    homeProvider.getPosition();
    print('MY ID: ${homeProvider.userId}');
    setState(() {
      uid = homeProvider.userId;
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  int uid = -1;

  @override
  Widget build(BuildContext context) {
    // final size = MediaQuery.of(context).size;
    return Consumer2<HomeProvider, PharmProvider>(
      builder: (_, homeProvider, pp, child) {
        return Scaffold(
          floatingActionButton: FloatingActionButton(
            onPressed: () => registerCustomer(pp),
            backgroundColor: Colors.white,
            elevation: 10,
            shape: const CircleBorder(),
            child: Icon(
              Icons.person_add_sharp,
              color: Colors.blue.shade400,
            ),
          ),
          body: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  margin: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: controller,
                          cursorColor: Colors.black,
                          cursorHeight: 20,
                          cursorWidth: .8,
                          keyboardType: selectedType,
                          onChanged: (value) {
                            WidgetsBinding.instance
                                .addPostFrameCallback((cb) async {
                              if (value.isEmpty) {
                                await pharmProvider.getCustomers(
                                    1, 100, context);
                              } else {
                                await pp.filtCustomers(
                                    filter, controller.text, context);
                              }
                            });
                          },
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            contentPadding:
                                const EdgeInsets.symmetric(horizontal: 20),
                            hintText: '$selectedFilter хайх',
                            hintStyle: const TextStyle(
                              color: Colors.black38,
                            ),
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          showMenu(
                            color: Colors.white,
                            context: context,
                            shadowColor: Colors.grey.shade500,
                            position:
                                const RelativeRect.fromLTRB(100, 100, 0, 0),
                            items: [
                              ...filters.map(
                                (f) => PopupMenuItem(
                                  child: Text(f),
                                  onTap: () => setFilter(f),
                                ),
                              )
                            ],
                          );
                        },
                        child: Container(
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20)),
                          margin: const EdgeInsets.only(right: 10),
                          padding: const EdgeInsets.all(5),
                          child: const Icon(
                            Icons.arrow_drop_down,
                            color: Colors.blue,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        ...pp.filteredCustomers.map(
                          (c) => customerBuilder(homeProvider, c),
                        ),
                        const SizedBox(height: kTextTabBarHeight + 20)
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  InkWell customerBuilder(HomeProvider homeProvider, Customer c) {
    return InkWell(
      onTap: () {
        homeProvider.changeSelectedCustomerId(c.id!);
        homeProvider.changeSelectedCustomerName(c.name!);
        homeProvider.changeIndex(1);
      },
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: shadow(),
        ),
        padding:
            const EdgeInsets.only(left: 20, top: 10, bottom: 10, right: 10),
        margin: const EdgeInsets.symmetric(vertical: 5),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      c.name!,
                      style: TextStyle(
                        color: (homeProvider.selectedCustomerId == c.id)
                            ? AppColors.succesColor
                            : Colors.grey.shade800,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    (c.loanBlock == true)
                        ? Text(
                            'Харилцагч дээр захиалга зээлээр өгөхгүй!',
                            style: TextStyle(
                              color: Colors.red.shade800,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          )
                        : const SizedBox(),
                  ],
                ),
                const SizedBox(width: 10),
                (c.location == false)
                    ? Text(
                        'Байршил тодорхойгүй',
                        style: TextStyle(
                            color: Colors.red.shade500,
                            fontSize: 12,
                            fontWeight: FontWeight.bold),
                      )
                    : const SizedBox(),
              ],
            ),
            InkWell(
              onTap: () => goto(CustomerDetailsPage(customer: c)),
              // getCustomerDetail(c),
              child: Icon(
                Icons.chevron_right_rounded,
                color: Colors.blue.shade700,
              ),
            )
          ],
        ),
      ),
    );
  }

  registerCustomer(PharmProvider pp) {
    Get.bottomSheet(
      Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: SingleChildScrollView(
          child: Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            runSpacing: 10,
            children: [
              const Align(
                alignment: Alignment.center,
                child: Text(
                  'Харилцагч бүртгэх',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
              input('Нэр', name, null, null),
              input('Регистрийн дугаар', rn, null, null),
              input('И-Мейл', email, validateEmail, null),
              input('Утас', phone, validatePhone, TextInputType.number
                ),
              input('Утас 2 - Заавал биш', phone2, validatePhone,
                  TextInputType.number ),
              input('Утас 3 - Заавал биш', phone3, validatePhone,
                  TextInputType.number),
              input('Нэмэлт тайлбар - Заавал биш', note, null, null),
              CustomButton(
                text: 'Бүртгэх',
                ontap: () {
                  if (name.text.isEmpty ||
                      rn.text.isEmpty ||
                      email.text.isEmpty ||
                      phone.text.isEmpty) {
                    message(message: 'Бүртгэл гүйцээнээ үү!', context: context);
                  } else {
                    pp
                        .registerCustomer(
                            name.text,
                            rn.text,
                            email.text,
                            phone.text,
                            phone2.text,
                            phone3.text,
                            note.text,
                            homeProvider.currentLatitude.toString(),
                            homeProvider.currentLongitude.toString(),
                            context)
                        .whenComplete(() => popSheet());
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  popSheet() {
    name.clear();
    phone.clear();
    note.clear();
    Navigator.pop(context);
  }
}

Widget input(String hint, TextEditingController contr,
    Function(String?)? validator, TextInputType? keyType) {
  return Container(
    decoration: BoxDecoration(
        color: Colors.grey.shade200, borderRadius: BorderRadius.circular(30)),
    child: Row(
      children: [
        Expanded(
          child: TextFormField(
            controller: contr,
            cursorColor: Colors.black,
            cursorHeight: 20,
            cursorWidth: .8,
            keyboardType: keyType,
            validator: validator as String? Function(String?)?,
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
