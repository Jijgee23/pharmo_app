import 'package:flutter/material.dart';
import 'package:pharmo_app/controllers/home_provider.dart';
import 'package:pharmo_app/utilities/colors.dart';
import 'package:pharmo_app/widgets/inputs/button.dart';
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
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Миний бүртгэл',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
      ),
      body: Container(
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              children: [
                info(
                  title: 'Имейл хаяг:',
                  value: home.userEmail!,
                ),
                info(
                  title: 'Хэрэглэгчийн төрөл:',
                  value: home.userRole == 'S'
                      ? 'Борлуулагч'
                      : home.userRole == 'D'
                          ? 'Түгээгч'
                          : 'Эмийн сан',
                ),
              ],
            ),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.grey.shade300,
              ),
              padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
              child: InkWell(
                onTap: () => confirmDeletion(),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.delete,
                        color: Colors.purple.shade700,
                      ),
                      const SizedBox(width: 20),
                      const Text('Бүртгэл устгах'),
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  info({required String title, required String value}) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.grey.shade300,
      ),
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10),
          ),
          Text(value,
              style: const TextStyle(
                  fontWeight: FontWeight.bold, color: AppColors.primary)),
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
                        onTap: () => Navigator.pop(context),
                        width: 150,
                      ),
                      Button(
                        text: 'Устгах',
                        onTap: () {
                          home.deactiveUser(pwd.text, context);
                        },
                        width: 150,
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
