import 'package:flutter/material.dart';
import 'package:pharmo_app/controllers/home_provider.dart';
import 'package:pharmo_app/controllers/pharms_provider.dart';
import 'package:pharmo_app/utilities/sizes.dart';
import 'package:pharmo_app/views/seller/customers.dart';
import 'package:pharmo_app/widgets/bottomSheet/my_sheet.dart';
import 'package:pharmo_app/widgets/dialog_and_messages/snack_message.dart';
import 'package:pharmo_app/widgets/inputs/custom_button.dart';
import 'package:provider/provider.dart';

class AddCustomer extends StatefulWidget {
  const AddCustomer({super.key});

  @override
  State<AddCustomer> createState() => _AddCustomerState();
}

class _AddCustomerState extends State<AddCustomer> {
  final TextEditingController name = TextEditingController();
  final TextEditingController rn = TextEditingController();
  final TextEditingController email = TextEditingController();
  final TextEditingController phone = TextEditingController();
  final TextEditingController phone2 = TextEditingController();
  final TextEditingController phone3 = TextEditingController();
  final TextEditingController note = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Consumer2<HomeProvider, PharmProvider>(
      builder: (context, home, pharm, child) => InkWell(
        onTap: () => registerCustomer(pharm, home),
        child: Container(
          padding: const EdgeInsets.all(5),
          decoration:
             const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
          child: Center(
            child: Icon(
              Icons.add,
              color: theme.primaryColor,
            ),
          ),
        ),
      ),
    );
  }

  registerCustomer(PharmProvider pp, HomeProvider home) {
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
                  ontap: () async => await _registerCustomer(pp, home)),
            ],
          ),
        ),
      ],
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
