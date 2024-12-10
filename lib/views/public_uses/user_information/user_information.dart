import 'package:flutter/material.dart';
import 'package:pharmo_app/controllers/home_provider.dart';
import 'package:pharmo_app/utilities/colors.dart';
import 'package:pharmo_app/utilities/constants.dart';
import 'package:pharmo_app/widgets/ui_help/box.dart';
import 'package:pharmo_app/widgets/ui_help/default_box.dart';
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
      backgroundColor: Theme.of(context).primaryColor,
      body: DefaultBox(
        title: 'Миний бүртгэл',
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Box(
              child: Column(
                children: [
                  info(
                    title: 'Хэрэглэгчийн нэр:',
                    value: home.userName!,
                  ),
                  info(
                    title: 'Имейл хаяг:',
                    value: home.userEmail!,
                  ),
                  info(
                    title: 'Хэрэглэгчийн төрөл:',
                    value: getRole(home.userRole!),
                  ),
                ],
              ),
            ),
            CustomButton(
                text: 'Бүртгэл устгах', ontap: () => confirmDeletion()),
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
        borderRadius: BorderRadius.circular(10),
        boxShadow: [Constants.defaultShadow],
        color: AppColors.background,
      ),
      padding: const EdgeInsets.all(10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  confirmDeletion() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final theme = Theme.of(context);
        return Dialog(
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.grey.shade300,
            ),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const Text(
                    'Нууц үгээ оруулна уу?',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
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
                        onTap: () {
                          home.deactiveUser(pwd.text, context);
                        },
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

  final TextEditingController pwd = TextEditingController();
}
