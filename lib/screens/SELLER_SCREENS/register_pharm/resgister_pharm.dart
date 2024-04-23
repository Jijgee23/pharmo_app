import 'package:flutter/material.dart';
import 'package:pharmo_app/controllers/seller_provider.dart';
import 'package:pharmo_app/models/pharm.dart';
import 'package:pharmo_app/widgets/custom_button.dart';
import 'package:pharmo_app/widgets/custom_text_filed.dart';
import 'package:provider/provider.dart';

// ignore: must_be_immutable
class RegisterPharm extends StatefulWidget {
  const RegisterPharm({super.key});

  @override
  State<RegisterPharm> createState() => _RegisterPharmState();
}

class _RegisterPharmState extends State<RegisterPharm> {
  late TextEditingController cNameController,
      cRdController,
      emailController,
      phoneController,
      provinceController,
      districtController,
      khorooController,
      detailedController;

  @override
  void initState() {
    cNameController = TextEditingController();
    cRdController = TextEditingController();
    emailController = TextEditingController();
    phoneController = TextEditingController();
    provinceController = TextEditingController();
    districtController = TextEditingController();
    khorooController = TextEditingController();
    detailedController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    // Dispose your controllers when they are no longer needed
    cNameController.dispose();
    cRdController.dispose();
    emailController.dispose();
    phoneController.dispose();
    provinceController.dispose();
    districtController.dispose();
    khorooController.dispose();
    detailedController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final sellerProvider = Provider.of<SellerProvider>(context);
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text('Эмийн сан бүртгэл'),
        ),
        body: Padding(
          padding: EdgeInsets.symmetric(
              vertical: size.height * 0.05, horizontal: size.width * 0.05),
          child: SingleChildScrollView(
            child: Wrap(
              direction: Axis.vertical,
              spacing: 20,
              children: [
                CustomTextField(
                  controller: cNameController,
                  hintText: 'Байгууллагын нэр',
                ),
                CustomTextField(
                  controller: cRdController,
                  hintText: 'Байгууллагын РД',
                ),
                CustomTextField(
                  controller: emailController,
                  hintText: 'Имэйл хаяг',
                ),
                CustomTextField(
                  controller: phoneController,
                  hintText: 'Утасны дугаар',
                ),
                CustomTextField(
                  controller: provinceController,
                  hintText: 'Аймаг/Хотын ID',
                ),
                CustomTextField(
                  controller: districtController,
                  hintText: 'Сум/Дүүргийн ID',
                ),
                CustomTextField(
                  controller: khorooController,
                  hintText: 'Баг/Хорооны ID',
                ),
                CustomTextField(
                  controller: detailedController,
                  hintText: 'Тайлбар',
                ),
                CustomButton(
                  text: 'Бүртгэх',
                  ontap: () {
                    print('button tapped');
                    sellerProvider.registerPharm(
                      Pharmo(
                        cNameController.text,
                        cRdController.text,
                        emailController.text,
                        phoneController.text,
                        Address(
                          provinceController.text,
                          districtController.text,
                          khorooController.text,
                          detailedController.text,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
