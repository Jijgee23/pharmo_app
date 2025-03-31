import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pharmo_app/controllers/home_provider.dart';
import 'package:pharmo_app/controllers/pharms_provider.dart';
import 'package:pharmo_app/controllers/models/delivery.dart';
import 'package:pharmo_app/utilities/colors.dart';
import 'package:pharmo_app/utilities/constants.dart';
import 'package:pharmo_app/utilities/sizes.dart';
import 'package:pharmo_app/views/main/seller/customers.dart';
import 'package:pharmo_app/widgets/dialog_and_messages/snack_message.dart';
import 'package:pharmo_app/widgets/inputs/custom_button.dart';
import 'package:provider/provider.dart';

class AddCustomer extends StatefulWidget {
  const AddCustomer({super.key});

  @override
  State<AddCustomer> createState() => _AddCustomerState();
}

class _AddCustomerState extends State<AddCustomer> {
  @override
  Widget build(BuildContext context) {
    return Consumer<PharmProvider>(
      builder: (context, pharm, child) => InkWell(
        onTap: () => registerCustomer(pharm),
        child: Container(
          height: 40,
          width: 40,
          decoration: const BoxDecoration(color: white, shape: BoxShape.circle),
          child: Center(child: Icon(Icons.add, color: theme.primaryColor)),
        ),
      ),
    );
  }

  registerCustomer(PharmProvider pp) {
    Get.bottomSheet(
      const AddCustomerSheet(),
      isScrollControlled: true,
    );
  }
}

class AddCustomerSheet extends StatefulWidget {
  const AddCustomerSheet({super.key});

  @override
  State<AddCustomerSheet> createState() => _AddCustomerSheetState();
}

class _AddCustomerSheetState extends State<AddCustomerSheet> {
  final TextEditingController name = TextEditingController();
  final TextEditingController rn = TextEditingController();
  final TextEditingController email = TextEditingController();
  final TextEditingController phone = TextEditingController();
  final TextEditingController phone2 = TextEditingController();
  final TextEditingController phone3 = TextEditingController();
  final TextEditingController note = TextEditingController();
  final formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Consumer2<PharmProvider, HomeProvider>(
      builder: (context, pp, home, child) => Container(
        padding: padding15,
        decoration: const BoxDecoration(
          color: white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Wrap(
              runSpacing: Sizes.smallFontSize,
              children: [
                Align(
                  alignment: Alignment.center,
                  child: Container(
                    height: 4,
                    width: 50,
                    decoration: BoxDecoration(
                        color: Colors.grey,
                        borderRadius: BorderRadius.circular(3)),
                  ),
                ),
                const Align(
                  alignment: Alignment.center,
                  child: Text(
                    'Харилцагч бүртгэх',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: black,
                        fontSize: 16),
                  ),
                ),
                input('Нэр', name, null),
                input('Регистрийн дугаар', rn, null),
                input('И-Мейл', email, null),
                input('Утас', phone,
                    const TextInputType.numberWithOptions(signed: true)),
                const Text('Заавал биш',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.black54)),
                input('Нэмэлт тайлбар ', note, null),
                const Text('Харилцагчийг бүсийг сонгоно уу!',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.black54)),
                if (pp.zones.isNotEmpty)
                  if (pp.zones.isNotEmpty)
                    SizedBox(
                      height: 50, // эсвэл тохирох өндөр өгнө
                      child: SingleChildScrollView(
                        scrollDirection:
                            Axis.horizontal, // Хэвтээ гүйлгэлт болгох
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Row(
                          spacing: 10,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            ...pp.zones.map((z) => zoneBuilder(z, pp)),
                          ],
                        ),
                      ),
                    ),
                CustomButton(
                    text: 'Бүртгэх',
                    ontap: () async => await _registerCustomer(pp, home)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  zoneBuilder(Zone zone, PharmProvider pharm) {
    bool selected = zone == pharm.selectedZone;
    return InkWell(
      onTap: () => pharm.setZone(zone),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding:
            EdgeInsets.symmetric(horizontal: selected ? 15 : 10, vertical: 7.5),
        decoration: BoxDecoration(
          color: white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
              color: selected ? succesColor : grey400, width: selected ? 2 : 1),
        ),
        child: Text(
          zone.name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  // Бүртгэх
  _registerCustomer(PharmProvider pp, HomeProvider home) async {
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
        home.currentLatitude.toString(),
        home.currentLongitude.toString(),
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
