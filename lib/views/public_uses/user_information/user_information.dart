import 'package:flutter/material.dart';
import 'package:pharmo_app/controllers/home_provider.dart';
import 'package:pharmo_app/utilities/colors.dart';
import 'package:pharmo_app/utilities/constants.dart';
import 'package:pharmo_app/utilities/sizes.dart';
import 'package:pharmo_app/widgets/appbar/side_menu_appbar.dart';
import 'package:pharmo_app/widgets/dialog_and_messages/snack_message.dart';
import 'package:pharmo_app/widgets/inputs/button.dart';
import 'package:pharmo_app/widgets/inputs/custom_button.dart';
import 'package:pharmo_app/widgets/inputs/custom_text_filed.dart';
import 'package:provider/provider.dart';

class UserInformation extends StatefulWidget {
  const UserInformation({super.key});

  @override
  State<UserInformation> createState() => _UserInformationState();
}

class _UserInformationState extends State<UserInformation> {
  late HomeProvider home;
  @override
  void initState() {
    home = Provider.of<HomeProvider>(context, listen: false);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const SideAppBar(text: 'Миний бүртгэл'),
      body: Padding(
        padding: const EdgeInsets.all(Sizes.smallFontSize),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              children: [
                info(title: 'Имейл хаяг:', value: home.userEmail!),
                info(title: 'Хэрэглэгчийн төрөл:', value: getRole(home.userRole!))
              ],
            ),
            CustomButton(text: 'Бүртгэл устгах', ontap: () => confirmDeletion())
          ],
        ),
      ),
    );
  }

  getRole(String r) {
    if (r == 'S') {
      return 'Борлуулагч';
    } else if (r == 'PA') {
      return 'Эмийн сангийн ажилтан';
    } else {
      return 'Түгээгч';
    }
  }

  info({required String title, required String value}) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 5),
      decoration: BoxDecoration(
        borderRadius: border20,
        color: primary.withOpacity(.3),
      ),
      padding: padding15,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold, color: black, fontSize: 16),
          ),
        ],
      ),
    );
  }

  confirmDeletion() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Container(
            padding: padding15,
            decoration: BoxDecoration(
              borderRadius: border20,
              color: white,
            ),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const Text(
                    'Нууц үгээ оруулна уу?',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  CustomTextField(
                    controller: pwd,
                    obscureText: true,
                    hintText: 'Нууц үг',
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Button(
                        text: 'Буцах',
                        color: theme.primaryColor,
                        onTap: () => Navigator.pop(context),
                        width: 100,
                      ),
                      Button(
                        text: 'Устгах',
                        color: theme.primaryColor,
                        onTap: () => _onDelete(),
                        width: 100,
                      )
                    ],
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  _onDelete() {
    if (pwd.text.isEmpty) {
      message('Нууц үг оруулна уу!');
    } else {
      home.deactiveUser(pwd.text, context);
    }
  }

  final TextEditingController pwd = TextEditingController();
}
